flashback table tmp_sms to before drop --flashback�ָ���ɾ���ı�
flashback table tmp_sms to timestamp(sysdate-5/1440);
flashback table tmp_sms to timestamp to_timestamp('2015-07-29 15:29:00','yyyy-mm-dd hh24:mi:ss');--SCN��system change number��Oracleһ���Լ����ʶ
/* select timestamp_to_scn(to_timestamp('2015-12-23 14:00:14:477501','yyyy-mm-dd hh24:mi:ss:ff')) from dual;
select systimestamp,timestamp_to_scn(sysdate) from dual;
flashback table family_reach_date to scn 14728866097374; */
select tablespace_name from dba_tablespaces;  --��ѯ���ؿ����б�ռ������
select table_name from user_object where object_name='LOCAL_AGENT_NAME'
select * from user_indexes where index_name='PK_ZBZGDM'  --��ѯ����PK_ZBZGDM���������б�����
select a.user_id,b.user_name from a,b where a.user_id=b.user_id(+)  --�����ӣ��ӱ�b���a�������ݣ�b���ظ����ݸ���a.user_id���ظ���ӣ�����
alter table ���� rename column�ɵ��ֶ��� to �µ��ֶ�����;
alter table ���� modify �ֶ��� ��������;
ALTER TABLE old_table_name RENAME TO new_table_name;
SELECT 'P' || S_PQ_ID.NEXTVAL, A.* FROM OPT_USER_INFO A;--Ϊ��A���Ψһ���б��
SELECT B.*,ROW_NUMBER() OVER(PARTITION BY B.USER_ID ORDER BY B.INSERT_DATE DESC) RNO FROM UNI_HF_LIST B  --����user_id����ѡ��insert_date���µ�һ��

select * from tmptable a where rowid not in (select max(rowid) from tmptable b where b.oper_no=a.oper_no)  --ɾ�������ظ���
select * from tmptable t where rowid not in (select max(rowid) from tmptable group by a,b) --ͬ��
select wm_concat(column_name) from (select * from all_tab_cols where table_name = 'OPT_TRANSFER_RPT' order by column_id) a--��ñ���������
select saddr,sid,serial#,paddr,username,status from v$session where username  is not null;--��ȡsession��Ϣ ��ɱ����session
alter system kill session 'sid,serial#';

show parameter recyclebin;--����recyclebinֻ�кô�û����
show parameter target;--����ռ�����ڴ�
select * from user_recyclebin;--select * from recyclebin;
select * from v$database;
select * from v$instance;--
select * from v$process t;
   
select t.form_id, t.user_id,t.serial_number,t.staff_id,a.staff_id,a.in_date
  from opt_user_info_n t,tmp_sms a
 where t.form_id in( '10006638','10006639','10006640','10006641')
     --and a.staff_id is null
	 --and a.staff_id(+) is null
	 --and a.staff_id is not null
   and t.user_id = a.user_id(+)--��(+)��ɸѡ�����Ӳ�ѯ,��(+)�����Ӳ�ѯ��ɸѡ
--��ѯ�����ʷ�汾
select versions_xid as xid,
       versions_startscn as startscn,
       versions_endscn as endscn,
       versions_operation as operation
  from tmp_sms versions between scn minvalue and maxvalue;

  
alter table tmp_sms ENABLE ROW MOVEMENT;
alter table tmp_sms shrink space;
SAVEPOINT AA;
ROLLBACK TO  SAVEPOINT AA;
purge table OPT_FSCQ9944_20160919110326;
--��session����DDL���ύuncommitted����������session����DDL�ᱨ����Դ��ռ��!!
where t.serial_number in����not inʱ���Ӳ�ѯҪ����where ...not null��!!
select * from recyclebin where 1 = 1 AND regexp_like(object_name, '^BIN[$]{1}.*==\$0$')

oracle job ʧ��16�κ�ϵͳ�Զ�ִ��exec dbms_job.broken(job���,false)��jobʧЧ





