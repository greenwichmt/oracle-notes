select t.TABLE_NAME ����,
       s.COMMENTS ��ע,
       t.COLUMN_ID,
       t.COLUMN_NAME �ֶ�����,
       t.DATA_TYPE ����,
       t.DATA_LENGTH ����,
       decode(t.NULLABLE, 'N', '��', 'Y', '��') �ɿ�,
       e.COMMENTS �ֶ�˵��
  from sys.USER_TAB_COLUMNS t, user_col_comments e, user_tab_comments s
 where t.TABLE_NAME in ('FL_INFO_FLOW',
                        'FL_INFO_FLOW_DEPART',
                        'FL_INFO_FLOW_OPER',
                        'INFO_ATTACH',
                        'INFO_ATTACH_DOWN_LOG')
   and e.COLUMN_NAME = t.COLUMN_NAME
   and e.TABLE_NAME = t.TABLE_NAME
   and s.TABLE_NAME(+) = t.TABLE_NAME

 
