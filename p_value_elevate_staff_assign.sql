CREATE OR REPLACE PROCEDURE p_value_elevate_staff_assign AS
  V_CENTRE_ID VARCHAR2(10);
  --V_DATE      DATE;
  V_COUNT     NUMBER;

  CURSOR CUR_CENTRE IS
    SELECT DISTINCT T.RANGE CENTRE_ID
      FROM UNI_OPERATION_RIGHT T
     WHERE T.EFFECTIVE_RANGE = 'CENTRE'
       AND T.OPERATION = 'UNI_HF_TASK_ASSIGN';

BEGIN
  --V_DATE := SYSDATE;
  ---------------------根据打标优先分配数据------------------
  UPDATE UNI_HF_LIST T
     SET (T.STAFF_ID, T.STAFF_NAME) = (SELECT A.OPER_NO, A.OPER_NAME
                                         FROM UNI_AUTH.SYS_OPER@DBCENTER A,
                                              UNI_ALL_LIFE_RELATION      B
                                        WHERE A.OPER_NO = B.STAFF_ID
                                          AND B.USER_ID = T.USER_ID)
   WHERE T.HF_TYPE IN ('51')
     AND T.STAFF_ID IS NULL
		 AND T.INSERT_DATE > TRUNC(SYSDATE)
		 AND EXISTS
          (SELECT 1
             FROM UNI_AUTH.SYS_OPER@DBCENTER A, UNI_ALL_LIFE_RELATION B
            WHERE A.OPER_NO = B.STAFF_ID
              AND B.USER_ID = T.USER_ID);
  COMMIT;
  ---------------------按营销中心的回访工号平均分配任务------------------
  FOR REC_CENTRE IN CUR_CENTRE LOOP
  
    V_CENTRE_ID := REC_CENTRE.CENTRE_ID;
  
    --获取该中心的客服经理人数
    SELECT COUNT(1)
      INTO V_COUNT
      FROM UNI_OPERATION_RIGHT T
     WHERE T.EFFECTIVE_RANGE = 'CENTRE'
       AND T.OPERATION = 'UNI_HF_TASK_ASSIGN'
       AND T.RANGE = V_CENTRE_ID;
  
    WHILE V_COUNT >= 1 LOOP
    
      UPDATE UNI_HF_LIST T
         SET (T.STAFF_ID, T.STAFF_NAME) = (SELECT A.OPER_NO, B.OPER_NAME
                                             FROM (SELECT T.OPER_NO,
                                                          ROWNUM RNO
                                                     FROM UNI_OPERATION_RIGHT T
                                                    WHERE T.EFFECTIVE_RANGE =
                                                          'CENTRE'
                                                      AND T.OPERATION =
                                                          'UNI_HF_TASK_ASSIGN'
                                                      AND T.RANGE =
                                                          V_CENTRE_ID) A,
                                                  UNI_AUTH.SYS_OPER@DBCENTER B
                                            WHERE A.OPER_NO = B.OPER_NO
                                              AND RNO = V_COUNT)
       WHERE T.HF_TYPE = '51'
         AND EXISTS
       (SELECT 1
                FROM (SELECT B.*
                        FROM (SELECT A.*, ROWNUM RNO
                                FROM UNI_HF_LIST A
                               WHERE A.HF_TYPE = '51'
                                 AND A.STAFF_ID IS NULL
																 AND V_CENTRE_ID = A.CENTRE_ID) B
																 --AND V_CENTRE_ID IN (A.CENTRE_ID,F_GET_NEWCENTER_BY_OLDCENTER(A.CENTRE_ID))) B
                       WHERE MOD(B.RNO, V_COUNT) = 0) C
               WHERE C.SEQ_ID = T.SEQ_ID);
      COMMIT;
      V_COUNT := V_COUNT - 1;
    
    END LOOP;
  END LOOP;

  -------------------------------------------------
  --后续操作
  -------------------------------------------------

END p_value_elevate_staff_assign;
/
