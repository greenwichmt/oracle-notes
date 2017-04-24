create or replace procedure P_FAMILY_VALUE_ELEVATE(I_DATA_table IN STRING,
                                                   I_DATA_FILE  IN STRING) as
  V_INSERT_DATE    date := SYSDATE;
  v_invalid_format number := 0;
  v_repeat_upload  number := 0;
  V_ULTIMATE_DEL   NUMBER := 0;
  V_VALID_UPLOAD   NUMBER := 0;

begin
  ---------------------预处理--------------------------
  --删除user_id格式错误
  EXECUTE IMMEDIATE 'delete from ' || I_DATA_table || ' t
           where not regexp_like(t.user_id,''^#[[:digit:]]+$'')';
  v_invalid_format := sql%rowcount;
  commit;
  --去掉user_id的井号
  EXECUTE IMMEDIATE 'update ' || I_DATA_table || ' t
          set t.user_id=substr(t.user_id,2)';
  commit;
  --删除重复数据
  EXECUTE IMMEDIATE 'delete from ' || I_DATA_table || ' t
           where t.rowid not in
                 (select max(a.rowid)
                    from ' || I_DATA_table || ' a
                   where t.user_id = a.user_id
									   and t.remark1 = a.remark1)';
  v_repeat_upload := sql%rowcount;
  commit;

  --------------余下不重复的user_id插入反馈表---------
  EXECUTE IMMEDIATE 'INSERT INTO FAMILY_VALUE_ELEVATE_FEEDBACK t
    SELECT T.*,sysdate,''导入无效-不在网''
      FROM ' || I_DATA_table || ' T';
  commit;
  UPDATE FAMILY_VALUE_ELEVATE_FEEDBACK T
     SET T.FEEDBACK = '导入成功-新增'
   WHERE EXISTS (SELECT 1
            FROM family_user_info_n A
           WHERE A.user_id = t.user_id
             and a.remove_tag = '0')
     and t.upload_date > sysdate - 5 / 1440;
  commit;
  UPDATE FAMILY_VALUE_ELEVATE_FEEDBACK T
     SET T.FEEDBACK = '导入成功-更新'
   WHERE EXISTS (SELECT 1
            FROM FAMILY_VALUE_ELEVATE_N A
           WHERE A.user_id = t.user_id
             and t.remark1 = a.remark1)
     and T.FEEDBACK = '导入成功-新增'
     and t.upload_date > sysdate - 5 / 1440;
  commit;
  --更新服务经理
  EXECUTE IMMEDIATE 'update uni_hf_list t
	set (t.staff_id,t.staff_name) = (select a.staff_id,(SELECT b.OPER_NAME
                           FROM UNI_AUTH.SYS_OPER@DBCENTER b
                          WHERE b.OPER_NO = a.STAFF_ID)
			 from ' || I_DATA_table || ' a
			where a.user_id = t.user_id
				and a.remark1 = t.remark)
	 where t.hf_type = ''51''
		 and exists (select 1
						from ' || I_DATA_table || ' a
					 where a.user_id = t.user_id
						 and a.remark1 = t.remark
						 and a.staff_id <> t.staff_id)';
  EXECUTE IMMEDIATE 'update family_value_elevate_n t
  set (t.yx_discnt,t.yx_deadline) = (select a.yx_discnt,a.yx_deadline
       from ' || I_DATA_table || ' a
      where a.user_id = t.user_id
        and a.remark1 = t.remark1)
   where exists (select 1
            from ' || I_DATA_table || ' a
           where a.user_id = t.user_id
             and a.remark1 = t.remark1)';
  commit;
  --删掉离网或同批次已存在的-留下可插入的
  EXECUTE IMMEDIATE 'DELETE FROM ' || I_DATA_table || ' T
   WHERE not EXISTS(SELECT 1 FROM FAMILY_USER_INFO_N N WHERE T.USER_ID=N.USER_ID AND N.REMOVE_TAG = ''0'')
	    OR EXISTS(SELECT 1 FROM FAMILY_VALUE_ELEVATE_N A WHERE T.USER_ID=A.USER_ID AND T.REMARK1=A.REMARK1)';
  V_ULTIMATE_DEL := sql%rowcount;
  commit;
  --有效导入count
  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || I_DATA_table
    INTO V_VALID_UPLOAD;
  --持久化表
  EXECUTE IMMEDIATE 'truncate table family_value_elevate';
  EXECUTE IMMEDIATE 'insert into family_value_elevate select * from ' ||
                    I_DATA_table;
  commit;

  --插入-价值提升宽表
  insert into family_value_elevate_n
    (user_id, yx_discnt, yx_deadline, remark1, remark2)
    select user_id, yx_discnt, yx_deadline, remark1, remark2
      from family_value_elevate t;
  ----------------------一系列更新-----------------------------
  --更新BSS沃家
  update family_value_elevate_n t
     set t.ois_wo_home = '1',
         t.is_wo_home  = '1',
         (            t.wo_home_open_date, t.wo_home_discnt_name) = (select a.open_date,
                                                                            a.product_name_b
                                                                       from family_user_uu a
                                                                      where t.user_id =
                                                                            a.user_id_b
                                                                        and a.net_type_code_b in
                                                                            ('71', '83')
                                                                        and a.end_date >
                                                                            sysdate
                                                                        and rownum = 1)
   where 1 = 1
     and exists (select 1
            from family_user_uu a
           where t.user_id = a.user_id_b
             and a.net_type_code_b in ('71', '83')
             and a.product_id_a in
                 ('80000574', '80000573', '80000576', '80000575',
                  '80000572', '80000570', '80000592', '80000593',
                  '80000594', '80000590', '80000591')
             and a.end_date > sysdate)
     AND T.IS_WO_HOME <> '1';
  COMMIT;
  --更新CBSS沃家
  update family_value_elevate_n t
     set t.ois_wo_home = '1',
         t.is_wo_home  = '1',
         (            t.wo_home_open_date, t.wo_home_discnt_name) = (select a.in_date_a,
                                                                            a.product_name_b
                                                                       from family_user_uu_cbss a
                                                                      where t.user_id =
                                                                            a.user_id_b
                                                                        and a.net_type_code_b in
                                                                            ('40')
                                                                        and a.end_date >
                                                                            sysdate
                                                                        and rownum = 1)
   where 1 = 1
     and exists (select 1
            from family_user_uu_cbss a
           where t.user_id = a.user_id_b
             and a.net_type_code_b in ('40')
             and a.end_date > sysdate)
     AND T.IS_WO_HOME <> '1';

  --更新沃TV/时间/套餐
  update family_value_elevate_n t
     set t.ois_wo_tv = '1',
         t.is_wo_tv  = '1',
         (          t.wo_tv_open_date, t.wo_tv_discnt_name) = (select a.tv_start_date,
                                                                      a.discnt_name
                                                                 from FAMILY_USER_TV a
                                                                where t.user_id =
                                                                      a.kd_user_id
                                                                  AND ROWNUM = 1)
   where 1 = 1
     AND T.IS_WO_TV <> '1'
     and exists (select 1
            from FAMILY_USER_TV a
           where t.user_id = a.kd_user_id
             and a.tv_finish_flag = '1'
             and a.tv_state_code = '0');
  COMMIT;

  ---------------------生成回访任务-----------------------
  INSERT INTO UNI_HF_LIST
    (SEQ_ID,
     USER_ID,
     CUST_ID,
     SERIAL_NUMBER,
     HF_TYPE,
     HF_TYPE_NAME,
     CUST_NAME,
     PSPT_ID,
     LINK_PHONE,
     SETUP_ADDR,
     PRODUCT_NAME,
     FINISH_DATE,
     AREA_ID,
     AREA_NAME,
     CENTRE_ID,
     CENTRE_NAME,
     AGENT_ID,
     AGENT_NAME,
     LOCAL_AGENT_NAME,
     LOCAL_AGENT_TYPE,
     INSERT_DATE,
     QUESTIONNAIRE_ID,
     REACH_DATE,
     BSS_REACH_DATE,
     UU_FLAG,
     UU_PRODUCT_ID,
     UU_PRODUCT_NAME,
     MISSION_MONTH,
     USER_NUMBER,
     GRID_ID,
     BUREAU_ID,
     RES_TYPE,
     GRID_NAME,
     BUREAU_NAME,
     REMARK,
     DISCNT_CODE,
     DISCNT_NAME,
     STAFF_ID)
    SELECT S_UNI_HF_ID.NEXTVAL, T1.*
      FROM (SELECT TO_CHAR(B.USER_ID) USER_ID,
                   TO_CHAR(B.CUST_ID) CUST_ID,
                   B.SERIAL_NUMBER,
                   '51' HF_TYPE,
                   '价值提升回访' HF_TYPE_NAME,
                   B.CUST_NAME,
                   B.PSPT_ID,
                   B.LINK_PHONE,
                   B.SETUP_ADDR,
                   B.PRODUCT_NAME,
                   B.FINISH_DATE,
                   B.AREA_ID,
                   B.AREA_NAME,
                   B.DEAL_CENTRE,
                   B.DEAL_CENTRE_NAME,
                   B.AGENT_ID,
                   B.AGENT_NAME,
                   B.LOCAL_AGENT_NAME,
                   B.LOCAL_AGENT_TYPE,
                   sysdate,
                   '10000000014',
                   A.REACH_DATE,
                   A.BSS_REACH_DATE,
                   A.UU_FLAG,
                   A.UU_PRODUCT_ID,
                   A.UU_PRODUCT_NAME,
                   TO_CHAR(sysdate, 'YYYYMM'),
                   B.USER_NUMBER,
                   B.GRID_ID,
                   B.BUREAU_ID,
                   A.RES_TYPE,
                   B.GRID_NAME,
                   B.BUREAU_NAME,
                   T.REMARK1,
                   B.DISCNT_CODE,
                   B.DISCNT_NAME,
                   T.STAFF_ID
              FROM FAMILY_REACH_DATE    A,
                   FAMILY_USER_INFO_N   B,
                   family_value_elevate T
             WHERE T.USER_ID = B.USER_ID
               AND T.USER_ID = A.USER_ID(+)
               AND A.REACH_DATE(+) >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1)) T1;
  COMMIT;
  delete from uni_hf_list t
   where t.hf_type = '51'
     and t.rowid not in (select min(a.rowid)
                           from uni_hf_list a
                          where a.hf_type = '51'
                            and a.user_id = t.user_id
                            and a.remark = t.remark);
  COMMIT;
  UPDATE UNI_HF_LIST T
     SET T.STAFF_NAME = (SELECT A.OPER_NAME
                           FROM UNI_AUTH.SYS_OPER@DBCENTER A
                          WHERE A.OPER_NO = T.STAFF_ID)
   WHERE T.HF_TYPE = '51'
     AND T.STAFF_NAME IS NULL
     AND EXISTS (SELECT 1
            FROM UNI_AUTH.SYS_OPER@DBCENTER A
           WHERE A.OPER_NO = T.STAFF_ID);
  COMMIT;
  UPDATE family_value_elevate_n t
     set t.syn_seq_id = (select a.seq_id
                           from uni_hf_list a
                          where a.hf_type = '51'
                            and t.user_id = a.user_id
                            and t.remark1 = a.remark)
   where t.syn_seq_id is null
     and exists (select 1
            from uni_hf_list a
           where a.hf_type = '51'
             and t.user_id = a.user_id
             and t.remark1 = a.remark);
	commit;
  --存储过程成功，删除临时表
  p_drop_table(I_DATA_table);

  --价值提升任务平均分配给服务经理
  p_value_elevate_staff_assign;

  --写日志发短信
  INSERT INTO FAMILY.FAMILY_EXEC_LOG
    (PROCEDURE_NAME, START_TIME, END_TIME)
  VALUES
    ('P_FAMILY_VALUE_ELEVATE', V_INSERT_DATE, SYSDATE);
  COMMIT;
  INSERT INTO MT_QUENE_757_NEW@ENG
    (SMS_ID, DEVICE_NUMBER, SMS, PRIORITY_CODE, SP_NUMBER)
    SELECT 1,
           '18688280722',
           '[10分钟内禁止导入]删除格式错误' || v_invalid_format || '-删除重复' ||
           v_repeat_upload || '-删除离网或更新已存在' || V_ULTIMATE_DEL || '-生成任务数' ||
           V_VALID_UPLOAD,
           99,
           '1001075701'
      FROM DUAL
		union all
    SELECT 1,
           '18688280832',
           '[10分钟内禁止导入]删除格式错误' || v_invalid_format || '-删除重复' ||
           v_repeat_upload || '-删除离网或更新已存在' || V_ULTIMATE_DEL || '-生成任务数' ||
           V_VALID_UPLOAD,
           99,
           '1001075701'
      FROM DUAL
    union all
    SELECT 1,
           '18688287187',
           '[10分钟内禁止导入]删除格式错误' || v_invalid_format || '-删除重复' ||
           v_repeat_upload || '-删除离网或更新已存在' || V_ULTIMATE_DEL || '-生成任务数' ||
           V_VALID_UPLOAD,
           99,
           '1001075701'
      FROM DUAL;
	COMMIT;


end P_FAMILY_VALUE_ELEVATE;
/
