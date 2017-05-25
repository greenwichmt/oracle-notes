select t.TABLE_NAME 表名,
       s.COMMENTS 表备注,
       t.COLUMN_ID,
       t.COLUMN_NAME 字段名称,
       t.DATA_TYPE 类型,
       t.DATA_LENGTH 长度,
       decode(t.NULLABLE, 'N', '否', 'Y', '是') 可空,
       e.COMMENTS 字段说明
  from sys.USER_TAB_COLUMNS t, user_col_comments e, user_tab_comments s
 where t.TABLE_NAME in ('FL_INFO_FLOW',
                        'FL_INFO_FLOW_DEPART',
                        'FL_INFO_FLOW_OPER',
                        'INFO_ATTACH',
                        'INFO_ATTACH_DOWN_LOG')
   and e.COLUMN_NAME = t.COLUMN_NAME
   and e.TABLE_NAME = t.TABLE_NAME
   and s.TABLE_NAME(+) = t.TABLE_NAME

 
