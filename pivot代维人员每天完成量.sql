P_AGENT_MAINTENANCE_WORKLOAD--生成代维人员工作量-供手机经分使用-每15min运行一次

--pivot方法实例-但适用版本 < oracle 11g
select *
  from (select 代维公司,代维分局,姓名,类别,
               to_char(trunc(sysdate) +
                       30 / 1440 *
                       ceil((操作时间 - trunc(sysdate)) / (30 / 1440)),
                       'hh24:mi"前"') as 时间段
          from yunwei.productivity@family t
         where trunc(t.操作时间) = trunc(sysdate))
 pivot(count(decode(类别,'故障',1,null)) as zj,count(decode(类别,'装机',1,null)) as wh for 时间段 in ('08:30前', '09:00前'));
 
--利用循环打印查询条件
begin
  for i in 17 .. 48 loop
    dbms_output.put_line('count(case when 时间段=''' ||
                         to_char(trunc(sysdate) + 1 / 48 * i, 'hh24:mi') ||
                         '前'' and 类别=''装机'' then 1 else null end) ' ||
                         to_char(trunc(sysdate) + 1 / 48 * i, 'hh24mi') || '装机' ||
                         to_char(i - 16) || ',');
    dbms_output.put_line('count(case when 时间段=''' ||
                         to_char(trunc(sysdate) + 1 / 48 * i, 'hh24:mi') ||
                         '前'' and 类别=''故障'' then 1 else null end) ' ||
                         to_char(trunc(sysdate) + 1 / 48 * i, 'hh24mi') || '故障' ||
                         to_char(i - 16) || ',');
  end loop;
end;

--打印出来的脚本
select * from (
with aim_table as(select 代维公司,代维分局,姓名,类别,
       to_char(trunc(操作时间) +
               30 / 1440 * ceil((操作时间 - trunc(操作时间)) / (30 / 1440)),
               'hh24:mi"前"') as 时间段,to_char(操作时间,'yyyymmdd') 操作日期
  from yunwei.productivity@family t
 where 操作时间 > to_date('20160907','yyyymmdd') and 操作时间 <= to_date('20160907','yyyymmdd')+1)
select 代维公司,代维分局,姓名,
count(case when 类别='装机' then 1 else null end) 装机总,
count(case when 类别='故障' then 1 else null end) 故障总,
count(case when 时间段='08:30前' and 类别='装机' then 1 else null end) 装机1,
count(case when 时间段='08:30前' and 类别='故障' then 1 else null end) 故障1,
count(case when 时间段='09:00前' and 类别='装机' then 1 else null end) 装机2,
count(case when 时间段='09:00前' and 类别='故障' then 1 else null end) 故障2,
count(case when 时间段='09:30前' and 类别='装机' then 1 else null end) 装机3,
count(case when 时间段='09:30前' and 类别='故障' then 1 else null end) 故障3,
count(case when 时间段='10:00前' and 类别='装机' then 1 else null end) 装机4,
count(case when 时间段='10:00前' and 类别='故障' then 1 else null end) 故障4,
count(case when 时间段='10:30前' and 类别='装机' then 1 else null end) 装机5,
count(case when 时间段='10:30前' and 类别='故障' then 1 else null end) 故障5,
count(case when 时间段='11:00前' and 类别='装机' then 1 else null end) 装机6,
count(case when 时间段='11:00前' and 类别='故障' then 1 else null end) 故障6,
count(case when 时间段='11:30前' and 类别='装机' then 1 else null end) 装机7,
count(case when 时间段='11:30前' and 类别='故障' then 1 else null end) 故障7,
count(case when 时间段='12:00前' and 类别='装机' then 1 else null end) 装机8,
count(case when 时间段='12:00前' and 类别='故障' then 1 else null end) 故障8,
count(case when 时间段='12:30前' and 类别='装机' then 1 else null end) 装机9,
count(case when 时间段='12:30前' and 类别='故障' then 1 else null end) 故障9,
count(case when 时间段='13:00前' and 类别='装机' then 1 else null end) 装机10,
count(case when 时间段='13:00前' and 类别='故障' then 1 else null end) 故障10,
count(case when 时间段='13:30前' and 类别='装机' then 1 else null end) 装机11,
count(case when 时间段='13:30前' and 类别='故障' then 1 else null end) 故障11,
count(case when 时间段='14:00前' and 类别='装机' then 1 else null end) 装机12,
count(case when 时间段='14:00前' and 类别='故障' then 1 else null end) 故障12,
count(case when 时间段='14:30前' and 类别='装机' then 1 else null end) 装机13,
count(case when 时间段='14:30前' and 类别='故障' then 1 else null end) 故障13,
count(case when 时间段='15:00前' and 类别='装机' then 1 else null end) 装机14,
count(case when 时间段='15:00前' and 类别='故障' then 1 else null end) 故障14,
count(case when 时间段='15:30前' and 类别='装机' then 1 else null end) 装机15,
count(case when 时间段='15:30前' and 类别='故障' then 1 else null end) 故障15,
count(case when 时间段='16:00前' and 类别='装机' then 1 else null end) 装机16,
count(case when 时间段='16:00前' and 类别='故障' then 1 else null end) 故障16,
count(case when 时间段='16:30前' and 类别='装机' then 1 else null end) 装机17,
count(case when 时间段='16:30前' and 类别='故障' then 1 else null end) 故障17,
count(case when 时间段='17:00前' and 类别='装机' then 1 else null end) 装机18,
count(case when 时间段='17:00前' and 类别='故障' then 1 else null end) 故障18,
count(case when 时间段='17:30前' and 类别='装机' then 1 else null end) 装机19,
count(case when 时间段='17:30前' and 类别='故障' then 1 else null end) 故障19,
count(case when 时间段='18:00前' and 类别='装机' then 1 else null end) 装机20,
count(case when 时间段='18:00前' and 类别='故障' then 1 else null end) 故障20,
count(case when 时间段='18:30前' and 类别='装机' then 1 else null end) 装机21,
count(case when 时间段='18:30前' and 类别='故障' then 1 else null end) 故障21,
count(case when 时间段='19:00前' and 类别='装机' then 1 else null end) 装机22,
count(case when 时间段='19:00前' and 类别='故障' then 1 else null end) 故障22,
count(case when 时间段='19:30前' and 类别='装机' then 1 else null end) 装机23,
count(case when 时间段='19:30前' and 类别='故障' then 1 else null end) 故障23,
count(case when 时间段='20:00前' and 类别='装机' then 1 else null end) 装机24,
count(case when 时间段='20:00前' and 类别='故障' then 1 else null end) 故障24,
count(case when 时间段='20:30前' and 类别='装机' then 1 else null end) 装机25,
count(case when 时间段='20:30前' and 类别='故障' then 1 else null end) 故障25,
count(case when 时间段='21:00前' and 类别='装机' then 1 else null end) 装机26,
count(case when 时间段='21:00前' and 类别='故障' then 1 else null end) 故障26,
count(case when 时间段='21:30前' and 类别='装机' then 1 else null end) 装机27,
count(case when 时间段='21:30前' and 类别='故障' then 1 else null end) 故障27,
count(case when 时间段='22:00前' and 类别='装机' then 1 else null end) 装机28,
count(case when 时间段='22:00前' and 类别='故障' then 1 else null end) 故障28,
count(case when 时间段='22:30前' and 类别='装机' then 1 else null end) 装机29,
count(case when 时间段='22:30前' and 类别='故障' then 1 else null end) 故障29,
count(case when 时间段='23:00前' and 类别='装机' then 1 else null end) 装机30,
count(case when 时间段='23:00前' and 类别='故障' then 1 else null end) 故障30,
count(case when 时间段='23:30前' and 类别='装机' then 1 else null end) 装机31,
count(case when 时间段='23:30前' and 类别='故障' then 1 else null end) 故障31,
count(case when 时间段='00:00前' and 类别='装机' then 1 else null end) 装机32,
count(case when 时间段='00:00前' and 类别='故障' then 1 else null end) 故障32
from aim_table group by 代维公司,代维分局,姓名 order by 代维公司,代维分局)
where 装机总+故障总>0;