DECLARE
  T_TABLE_NAME varchar2(20) := 'DM_R3G_$YYYYMM'; --表名DM_R3G_INFO_$YYYYMM
  T_TIMEST     VARCHAR2(8) := '20160218'; --20160218
  T_OPER_NO    VARCHAR2(20); --申请人工号FSJF5813
  T_IP         VARCHAR2(20); --申请人IP127.0.0.1

  IS_EXISTS     NUMBER; --分区表 是否存在
  T_YEAR        VARCHAR2(4); --
  T_MONTH       VARCHAR2(2); --
  T_DAY         VARCHAR2(2); --
  T_YEAR_MONTH  VARCHAR2(6); --
  T_DATA_SOURCE VARCHAR2(50); --R3G_INFO_DAY@LINK_FSDB
  T_DATA_FILTER VARCHAR2(100); --TIMEST = TO_DATE('$YYYYMMDD', 'YYYYMMDD')
  T_CREATE_MODE VARCHAR2(10); --获取模式 003-年按月分区 004-月按日分区

  T_PARTITION_NUM NUMBER;

  type TYPE_CUR IS REF CURSOR; ------------------------用引用游标添加分区表DM_R3G_INFO_201602的columns
  CUR_TABLE_COLS TYPE_CUR;
  T_COLUMN_NAME  ALL_TAB_COLUMNS.COLUMN_NAME%TYPE;
  T_DATA_TYPE    ALL_TAB_COLUMNS.DATA_TYPE%TYPE;
  T_DATA_LENGTH  ALL_TAB_COLUMNS.DATA_LENGTH%TYPE;
  T_COL_INFO     VARCHAR2(50);

  IS_COL_IN_TABLE NUMBER := 0;
  T_INSERT_COLS   VARCHAR2(8000);
BEGIN
  --第一步
  --SELECT * FROM DM_CODE_TABLE A WHERE A.TABLE_NAME = 'DM_R3G_INFO_$YYYYMM';
  BEGIN
    SELECT DATA_SOURCE, DATA_FILTER, CREATE_MODE
      INTO T_DATA_SOURCE, T_DATA_FILTER, T_CREATE_MODE
      FROM DM_CODE_TABLE@fs_dbcenter T
     WHERE T.TABLE_NAME = T_TABLE_NAME;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000,
                              '表名' || TRIM(T_TABLE_NAME) || '无效');
  END;

  --日期处理，把T_TIMEST转成YYYYMM YYYY MM
  T_YEAR_MONTH := TO_CHAR(TO_DATE(T_TIMEST, 'YYYYMMDD'), 'YYYYMM');
  T_YEAR       := TO_CHAR(TO_DATE(T_TIMEST, 'YYYYMMDD'), 'YYYY');
  T_MONTH      := TO_CHAR(TO_DATE(T_TIMEST, 'YYYYMMDD'), 'MM');
  T_DAY        := TO_CHAR(TO_DATE(T_TIMEST, 'YYYYMMDD'), 'DD');
  --变量替换
  T_TABLE_NAME  := REPLACE(T_TABLE_NAME, '$YYYYMM', T_YEAR_MONTH); --DM_R3G_INFO_201602
  T_TABLE_NAME  := REPLACE(T_TABLE_NAME, '$YYYY', T_YEAR);
  T_TABLE_NAME  := REPLACE(T_TABLE_NAME, '$MM', T_MONTH);
  T_DATA_FILTER := REPLACE(T_DATA_FILTER, '$YYYYMMDD', T_TIMEST);
  T_DATA_FILTER := REPLACE(T_DATA_FILTER, '$YYYYMM', T_YEAR_MONTH);
  T_DATA_FILTER := REPLACE(T_DATA_FILTER, '$YYYY', T_YEAR);
  T_DATA_FILTER := REPLACE(T_DATA_FILTER, '$MM', T_MONTH);
  T_DATA_SOURCE := REPLACE(T_DATA_SOURCE, '$YYYYMM', T_YEAR_MONTH);
  T_DATA_SOURCE := REPLACE(T_DATA_SOURCE, '$YYYY', T_YEAR);
  T_DATA_SOURCE := REPLACE(T_DATA_SOURCE, '$MM', T_MONTH);

  --第二步 创建数据临时表
  P_DROP_TABLE('TMP_' || T_TABLE_NAME);
  --拼SQL,把数据放临时表
  EXECUTE IMMEDIATE 'CREATE TABLE TMP_' || T_TABLE_NAME ||
                    ' NOLOGGING AS
                    SELECT * FROM ' || T_DATA_SOURCE ||
                    ' A ' || (CASE
                      WHEN TRIM(T_DATA_FILTER) IS NOT NULL THEN
                       ' WHERE ' || TRIM(T_DATA_FILTER)
                      ELSE
                       NULL
                    END);
  
  --判断创建模式
  
  --第三步：1、判断表是否存在，如果不存在，创建一个空表先
  SELECT COUNT(1)
    INTO IS_EXISTS
    FROM ALL_TABLES A
   WHERE A.TABLE_NAME = T_TABLE_NAME
     AND A.OWNER = USER;
  
  --如果表不存在创建分区表
  IF IS_EXISTS = 0 THEN
    if T_CREATE_MODE = '003' THEN
      T_PARTITION_NUM := 12;
    ELSIF T_CREATE_MODE = '004' THEN
      T_PARTITION_NUM := 31;
    END IF;
    EXECUTE IMMEDIATE '
       CREATE TABLE ' || T_TABLE_NAME || '
          (
            P_ID              VARCHAR2(2)
          )
          PARTITION BY LIST (P_ID)
          (
              PARTITION ' || T_TABLE_NAME || '_P01 VALUES (''01'')
          )';
    FOR T_TMP_I IN 2 .. T_PARTITION_NUM LOOP
      EXECUTE IMMEDIATE '
              ALTER TABLE ' || T_TABLE_NAME ||
                        ' ADD PARTITION ' || T_TABLE_NAME || '_P' ||
                        LPAD(T_TMP_I, 2, '0') || ' VALUES(''' ||
                        LPAD(T_TMP_I, 2, '0') || ''')';
    END LOOP;
    OPEN CUR_TABLE_COLS FOR 'SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH FROM ALL_TAB_COLUMNS A 
                             WHERE A.OWNER = ''' || user || ''' AND A.TABLE_NAME = ''TMP_' || T_TABLE_NAME || ''' AND COLUMN_NAME != ''P_ID''';
    LOOP
      EXIT WHEN CUR_TABLE_COLS%NOTFOUND;
      FETCH CUR_TABLE_COLS
        INTO T_COLUMN_NAME, T_DATA_TYPE, T_DATA_LENGTH; --IS_COL_IN_TABLE
      /*EXECUTE IMMEDIATE 'SELECT SUM(CASE WHEN COLUMN_NAME = ' ||
                        T_COLUMN_NAME ||
                        ' THEN 1 OTHERS THEN 0 END) 
                           WHERE A.OWNER = ''' || user ||
                        ''' AND A.TABLE_NAME = ' || T_TABLE_NAME ||
                        ' GROUP BY TABLE_NAME '
        INTO IS_COL_IN_TABLE;
      IF IS_COL_IN_TABLE = 0 THEN
        SELECT T_COLUMN_NAME || ' ' || T_DATA_TYPE ||
               DECODE(T_DATA_TYPE,
                      'VARCHAR2',
                      '(' || T_DATA_LENGTH || ')',
                      '')
          INTO T_COL_INFO
          FROM DUAL;
        EXECUTE IMMEDIATE 'ALTER TABLE ' || T_TABLE_NAME || ' ADD (' ||
                          T_COL_INFO || ')';
      ELSE
        NULL;
      END IF;*/ --不存在的列都插入
      SELECT T_COLUMN_NAME || ' ' || T_DATA_TYPE ||
             DECODE(T_DATA_TYPE,
                    'VARCHAR2',
                    '(' || T_DATA_LENGTH || ')',
                    '')
        INTO T_COL_INFO
        FROM DUAL;
      EXECUTE IMMEDIATE 'ALTER TABLE ' || T_TABLE_NAME || ' ADD (' ||
                        T_COL_INFO || ')';
      --IS_COL_IN_TABLE := 0;
    END LOOP;
    CLOSE CUR_TABLE_COLS; --游标结束,分区表的列已全部创建
  END IF;

  /*清空分区*/
  EXECUTE IMMEDIATE 'ALTER TABLE ' || T_TABLE_NAME ||
                    ' TRUNCATE PARTITION ' || T_TABLE_NAME || '_P' || (CASE
                      WHEN T_CREATE_MODE = '003' THEN
                       LPAD(T_DAY, 2, '0')
                      WHEN T_CREATE_MODE = '004' THEN
                       LPAD(T_MONTH, 2, '0')
                    END) || ' UPDATE GLOBAL INDEXES';

  SELECT WM_CONCAT(A.COLUMN_NAME)
    INTO T_INSERT_COLS
    FROM ALL_TAB_COLS A
   WHERE A.TABLE_NAME = 'TMP_' || T_TABLE_NAME
     AND A.OWNER = USER
     AND A.COLUMN_NAME != 'P_ID';

  --正式保存数据
  execute immediate '
     INSERT INTO ' || T_TABLE_NAME || ' PARTITION(' ||
                    T_TABLE_NAME || '_P' || (CASE
                      WHEN T_CREATE_MODE = '003' THEN
                       LPAD(T_DAY, 2, '0')
                      WHEN T_CREATE_MODE = '004' THEN
                       LPAD(T_MONTH, 2, '0')
                    END) || ') NOLOGGING (P_ID, ' || T_INSERT_COLS || ')
      select ''' || (CASE
                      WHEN T_CREATE_MODE = '003' THEN
                       LPAD(T_DAY, 2, '0')
                      WHEN T_CREATE_MODE = '004' THEN
                       LPAD(T_MONTH, 2, '0')
                    END) || ''' P_ID, ' || T_INSERT_COLS || ' from TMP_' ||
                    T_TABLE_NAME;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_LINE(SQLCODE || ':' || SQLERRM);
END;
