flashback table tmp_sms to before drop --flashback恢复刚删除的表
flashback table tmp_sms to timestamp(sysdate-5/1440);
flashback table tmp_sms to timestamp to_timestamp('2015-07-29 15:29:00','yyyy-mm-dd hh24:mi:ss');--SCN即system change number是Oracle一致性检验标识
/* select timestamp_to_scn(to_timestamp('2015-12-23 14:00:14:477501','yyyy-mm-dd hh24:mi:ss:ff')) from dual;
select systimestamp,timestamp_to_scn(sysdate) from dual;
flashback table family_reach_date to scn 14728866097374; */
select tablespace_name from dba_tablespaces;  --查询本地库所有表空间的名称
select table_name from user_object where object_name='LOCAL_AGENT_NAME'
select * from user_indexes where index_name='PK_ZBZGDM'  --查询包含PK_ZBZGDM索引的所有表索引
select a.user_id,b.user_name from a,b where a.user_id=b.user_id(+)  --左连接，从表b向表a补充数据，b中重复数据复制a.user_id后重复添加！！！
alter table 表名 rename column旧的字段名 to 新的字段名名;
alter table 表名 modify 字段名 数据类型;
ALTER TABLE old_table_name RENAME TO new_table_name;
SELECT 'P' || S_PQ_ID.NEXTVAL, A.* FROM OPT_USER_INFO A;--为表A添加唯一序列编号
SELECT B.*,ROW_NUMBER() OVER(PARTITION BY B.USER_ID ORDER BY B.INSERT_DATE DESC) RNO FROM UNI_HF_LIST B  --按照user_id分组选择insert_date最新的一条

select * from tmptable a where rowid not in (select max(rowid) from tmptable b where b.oper_no=a.oper_no)  --删除表里重复行
select * from tmptable t where rowid not in (select max(rowid) from tmptable group by a,b) --同上
select wm_concat(column_name) from (select * from all_tab_cols where table_name = 'OPT_TRANSFER_RPT' order by column_id) a--获得表所有列名
select saddr,sid,serial#,paddr,username,status from v$session where username  is not null;--获取session信息 后杀掉此session
alter system kill session 'sid,serial#';

show parameter recyclebin;--启用recyclebin只有好处没坏处
show parameter target;--各项占多少内存
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
   and t.user_id = a.user_id(+)--有(+)先筛选后连接查询,无(+)先连接查询后筛选
--查询表的历史版本
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
--本session做的DDL会提交uncommitted操作，其他session做的DDL会报错资源被占用!!
where t.serial_number in或者not in时候（子查询要加上where ...not null）!!
select * from recyclebin where 1 = 1 AND regexp_like(object_name, '^BIN[$]{1}.*==\$0$')

oracle job 失败16次后，系统自动执行exec dbms_job.broken(job编号,false)让job失效





