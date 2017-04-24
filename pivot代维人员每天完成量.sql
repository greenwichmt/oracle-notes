P_AGENT_MAINTENANCE_WORKLOAD--���ɴ�ά��Ա������-���ֻ�����ʹ��-ÿ15min����һ��

--pivot����ʵ��-�����ð汾 < oracle 11g
select *
  from (select ��ά��˾,��ά�־�,����,���,
               to_char(trunc(sysdate) +
                       30 / 1440 *
                       ceil((����ʱ�� - trunc(sysdate)) / (30 / 1440)),
                       'hh24:mi"ǰ"') as ʱ���
          from yunwei.productivity@family t
         where trunc(t.����ʱ��) = trunc(sysdate))
 pivot(count(decode(���,'����',1,null)) as zj,count(decode(���,'װ��',1,null)) as wh for ʱ��� in ('08:30ǰ', '09:00ǰ'));
 
--����ѭ����ӡ��ѯ����
begin
  for i in 17 .. 48 loop
    dbms_output.put_line('count(case when ʱ���=''' ||
                         to_char(trunc(sysdate) + 1 / 48 * i, 'hh24:mi') ||
                         'ǰ'' and ���=''װ��'' then 1 else null end) ' ||
                         to_char(trunc(sysdate) + 1 / 48 * i, 'hh24mi') || 'װ��' ||
                         to_char(i - 16) || ',');
    dbms_output.put_line('count(case when ʱ���=''' ||
                         to_char(trunc(sysdate) + 1 / 48 * i, 'hh24:mi') ||
                         'ǰ'' and ���=''����'' then 1 else null end) ' ||
                         to_char(trunc(sysdate) + 1 / 48 * i, 'hh24mi') || '����' ||
                         to_char(i - 16) || ',');
  end loop;
end;

--��ӡ�����Ľű�
select * from (
with aim_table as(select ��ά��˾,��ά�־�,����,���,
       to_char(trunc(����ʱ��) +
               30 / 1440 * ceil((����ʱ�� - trunc(����ʱ��)) / (30 / 1440)),
               'hh24:mi"ǰ"') as ʱ���,to_char(����ʱ��,'yyyymmdd') ��������
  from yunwei.productivity@family t
 where ����ʱ�� > to_date('20160907','yyyymmdd') and ����ʱ�� <= to_date('20160907','yyyymmdd')+1)
select ��ά��˾,��ά�־�,����,
count(case when ���='װ��' then 1 else null end) װ����,
count(case when ���='����' then 1 else null end) ������,
count(case when ʱ���='08:30ǰ' and ���='װ��' then 1 else null end) װ��1,
count(case when ʱ���='08:30ǰ' and ���='����' then 1 else null end) ����1,
count(case when ʱ���='09:00ǰ' and ���='װ��' then 1 else null end) װ��2,
count(case when ʱ���='09:00ǰ' and ���='����' then 1 else null end) ����2,
count(case when ʱ���='09:30ǰ' and ���='װ��' then 1 else null end) װ��3,
count(case when ʱ���='09:30ǰ' and ���='����' then 1 else null end) ����3,
count(case when ʱ���='10:00ǰ' and ���='װ��' then 1 else null end) װ��4,
count(case when ʱ���='10:00ǰ' and ���='����' then 1 else null end) ����4,
count(case when ʱ���='10:30ǰ' and ���='װ��' then 1 else null end) װ��5,
count(case when ʱ���='10:30ǰ' and ���='����' then 1 else null end) ����5,
count(case when ʱ���='11:00ǰ' and ���='װ��' then 1 else null end) װ��6,
count(case when ʱ���='11:00ǰ' and ���='����' then 1 else null end) ����6,
count(case when ʱ���='11:30ǰ' and ���='װ��' then 1 else null end) װ��7,
count(case when ʱ���='11:30ǰ' and ���='����' then 1 else null end) ����7,
count(case when ʱ���='12:00ǰ' and ���='װ��' then 1 else null end) װ��8,
count(case when ʱ���='12:00ǰ' and ���='����' then 1 else null end) ����8,
count(case when ʱ���='12:30ǰ' and ���='װ��' then 1 else null end) װ��9,
count(case when ʱ���='12:30ǰ' and ���='����' then 1 else null end) ����9,
count(case when ʱ���='13:00ǰ' and ���='װ��' then 1 else null end) װ��10,
count(case when ʱ���='13:00ǰ' and ���='����' then 1 else null end) ����10,
count(case when ʱ���='13:30ǰ' and ���='װ��' then 1 else null end) װ��11,
count(case when ʱ���='13:30ǰ' and ���='����' then 1 else null end) ����11,
count(case when ʱ���='14:00ǰ' and ���='װ��' then 1 else null end) װ��12,
count(case when ʱ���='14:00ǰ' and ���='����' then 1 else null end) ����12,
count(case when ʱ���='14:30ǰ' and ���='װ��' then 1 else null end) װ��13,
count(case when ʱ���='14:30ǰ' and ���='����' then 1 else null end) ����13,
count(case when ʱ���='15:00ǰ' and ���='װ��' then 1 else null end) װ��14,
count(case when ʱ���='15:00ǰ' and ���='����' then 1 else null end) ����14,
count(case when ʱ���='15:30ǰ' and ���='װ��' then 1 else null end) װ��15,
count(case when ʱ���='15:30ǰ' and ���='����' then 1 else null end) ����15,
count(case when ʱ���='16:00ǰ' and ���='װ��' then 1 else null end) װ��16,
count(case when ʱ���='16:00ǰ' and ���='����' then 1 else null end) ����16,
count(case when ʱ���='16:30ǰ' and ���='װ��' then 1 else null end) װ��17,
count(case when ʱ���='16:30ǰ' and ���='����' then 1 else null end) ����17,
count(case when ʱ���='17:00ǰ' and ���='װ��' then 1 else null end) װ��18,
count(case when ʱ���='17:00ǰ' and ���='����' then 1 else null end) ����18,
count(case when ʱ���='17:30ǰ' and ���='װ��' then 1 else null end) װ��19,
count(case when ʱ���='17:30ǰ' and ���='����' then 1 else null end) ����19,
count(case when ʱ���='18:00ǰ' and ���='װ��' then 1 else null end) װ��20,
count(case when ʱ���='18:00ǰ' and ���='����' then 1 else null end) ����20,
count(case when ʱ���='18:30ǰ' and ���='װ��' then 1 else null end) װ��21,
count(case when ʱ���='18:30ǰ' and ���='����' then 1 else null end) ����21,
count(case when ʱ���='19:00ǰ' and ���='װ��' then 1 else null end) װ��22,
count(case when ʱ���='19:00ǰ' and ���='����' then 1 else null end) ����22,
count(case when ʱ���='19:30ǰ' and ���='װ��' then 1 else null end) װ��23,
count(case when ʱ���='19:30ǰ' and ���='����' then 1 else null end) ����23,
count(case when ʱ���='20:00ǰ' and ���='װ��' then 1 else null end) װ��24,
count(case when ʱ���='20:00ǰ' and ���='����' then 1 else null end) ����24,
count(case when ʱ���='20:30ǰ' and ���='װ��' then 1 else null end) װ��25,
count(case when ʱ���='20:30ǰ' and ���='����' then 1 else null end) ����25,
count(case when ʱ���='21:00ǰ' and ���='װ��' then 1 else null end) װ��26,
count(case when ʱ���='21:00ǰ' and ���='����' then 1 else null end) ����26,
count(case when ʱ���='21:30ǰ' and ���='װ��' then 1 else null end) װ��27,
count(case when ʱ���='21:30ǰ' and ���='����' then 1 else null end) ����27,
count(case when ʱ���='22:00ǰ' and ���='װ��' then 1 else null end) װ��28,
count(case when ʱ���='22:00ǰ' and ���='����' then 1 else null end) ����28,
count(case when ʱ���='22:30ǰ' and ���='װ��' then 1 else null end) װ��29,
count(case when ʱ���='22:30ǰ' and ���='����' then 1 else null end) ����29,
count(case when ʱ���='23:00ǰ' and ���='װ��' then 1 else null end) װ��30,
count(case when ʱ���='23:00ǰ' and ���='����' then 1 else null end) ����30,
count(case when ʱ���='23:30ǰ' and ���='װ��' then 1 else null end) װ��31,
count(case when ʱ���='23:30ǰ' and ���='����' then 1 else null end) ����31,
count(case when ʱ���='00:00ǰ' and ���='װ��' then 1 else null end) װ��32,
count(case when ʱ���='00:00ǰ' and ���='����' then 1 else null end) ����32
from aim_table group by ��ά��˾,��ά�־�,���� order by ��ά��˾,��ά�־�)
where װ����+������>0;