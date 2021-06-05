select FCRS.request_id,ltrim((SELECT distinct upper(meaning) FROM apps.fnd_lookup_values look WHERE FCRS.phase_code = look.lookup_code AND look.lookup_type = 'CP_PHASE_CODE' and rownum=1)) "PHASE CODE",
       ltrim((SELECT distinct upper(meaning) FROM apps.fnd_lookup_values look WHERE FCRS.status_code = lookup_code AND look.lookup_type = 'CP_STATUS_CODE' and rownum=1)) "STATUS CODE",
       FCRS.USER_CONCURRENT_PROGRAM_NAME,FCRS.REQUESTOR,FCRS.request_date,FCRS.COMPLETION_TEXT,
       to_char(round(((nvl(FCRS.ACTUAL_COMPLETION_DATE,sysdate)-FCRS.ACTUAL_START_DATE)*24*60),2),'9G99999D99')||' Minutes |'||to_char(round(((nvl(FCRS.ACTUAL_COMPLETION_DATE,sysdate)-FCRS.ACTUAL_START_DATE)*24),2),'9G9999D99')
       ||' Hours |'||to_char(round(((nvl(FCRS.ACTUAL_COMPLETION_DATE,sysdate)-FCRS.ACTUAL_START_DATE)),2),'9G999D99')||' Days' "Run Time",
       (select cqt.USER_CONCURRENT_QUEUE_NAME from apps.fnd_concurrent_queues_tl cqt,apps.fnd_concurrent_processes cp
       where FCRS.controlling_manager =cp.concurrent_process_id and cqt.CONCURRENT_QUEUE_ID = cp.concurrent_queue_id and rownum=1) "Concurrent Manager",(select rv.RESPONSIBILITY_NAME from apps.fnd_responsibility_vl rv where rv.responsibility_id=FCRS.responsibility_id) "Run From",
       PARENT_REQUEST_ID,FCRS.DESCRIPTION,FCRS.PROGRAM_SHORT_NAME,FCRS.ARGUMENT_TEXT--,FCRS.*
from apps.fnd_conc_req_summary_v FCRS
where 1=1--FCRS.REQUESTOR='INTERFACE'
--Where request_id in ('')
--where program_short_name like ''
--and PHASE_CODE='R' and STATUS_CODE='R'
and user_concurrent_program_name like  'Data extraction worker'--'Corsair EDI 855 - PO Acknowledgement'--
--'Corsair MSC Generate Targeted and Net Zip Files'--Corsair Commercial Invoice - A4'--'%Origin%Commercial%'
--where FCRS.description ='Appworx_'||&Alertkey_from_email
--where requestor NOT IN ('APPWORX-PACRIM', 'APPWORX-STD','APPWORX-EMEA','APPWORX','SYSADMIN')
--and trunc(request_date) BETWEEN TO_DATE ('28-MAR-2014') AND TO_DATE ('31-MAR-2014')
--and trunc(request_date) BETWEEN '28-MAR-2014' AND '31-MAR-2014'
and argument_text like '%BOOKING_HISTORY_BI%'
order by FCRS.request_date desc;

SELECT unique a.REQUEST_ID,ltrim((SELECT distinct upper(meaning) FROM apps.fnd_lookup_values look WHERE a.phase_code = look.lookup_code AND look.lookup_type = 'CP_PHASE_CODE' and rownum=1)) "PHASE CODE",
       ltrim((SELECT distinct upper(meaning) FROM apps.fnd_lookup_values look WHERE a.status_code = lookup_code AND look.lookup_type = 'CP_STATUS_CODE' and rownum=1)) "STATUS CODE",
       (select cpt.user_concurrent_program_name from apps.fnd_concurrent_programs_tl cpt where cpt.concurrent_program_id=a.concurrent_program_id and rownum=1) user_concurrent_program_name,e.sql_id,e.sql_text,A.REQUEST_DATE,
       (select responsibility_name from apps.fnd_responsibility_vl rt where rt.RESPONSIBILITY_ID=a.RESPONSIBILITY_ID) "Run From",(select USER_NAME from apps.fnd_user fu where a.requested_by=fu.user_id) Requestor,
       (select cqt.USER_CONCURRENT_QUEUE_NAME from apps.fnd_concurrent_queues_tl cqt,apps.fnd_concurrent_processes cp
        where a.controlling_manager =cp.concurrent_process_id and cqt.CONCURRENT_QUEUE_ID = cp.concurrent_queue_id and rownum=1) "Concurrent Manager",
       to_char(round(((nvl(a.ACTUAL_COMPLETION_DATE,sysdate)-a.ACTUAL_START_DATE)*24*60),2),'9G99999D99')||' Minutes |'||to_char(round(((nvl(a.ACTUAL_COMPLETION_DATE,sysdate)-a.ACTUAL_START_DATE)*24),2),'9G9999D99')
       ||' Hours |'||to_char(round(((nvl(a.ACTUAL_COMPLETION_DATE,sysdate)-a.ACTUAL_START_DATE)),2),'9G999D99')||' Days' "Run Time",a.COMPLETION_TEXT,a.ARGUMENT_TEXT,D.SID,a.description,PARENT_REQUEST_ID,a.REQUEST_TYPE,c.USERNAME,c.SERIAL#,c.TERMINAL,c.PROGRAM,d.USERNAME as db_user,d.STATUS,d.SERVER,d.SCHEMANAME,d.OSUSER,d.TERMINAL,d.PROGRAM,E.PIECE
FROM APPS.FND_CONCURRENT_REQUESTS A,GV$PROCESS C ,GV$SESSION D ,GV$SQLTEXT E,apps.fnd_concurrent_programs_tl cpt
WHERE  C.SPID = A.ORACLE_PROCESS_ID AND D.sql_address = E .address AND D.sql_hash_value = E.hash_value and D. PADDR= C. ADDR AND cpt.concurrent_program_id=a.concurrent_program_id and PHASE_CODE='R' and STATUS_CODE='R'
--and d.sid =''
AND cpt.user_concurrent_program_name like 'Data extraction worker'
--and a.description ='Appworx_'||&Alertkey_from_email
--and a.REQUEST_ID='316638515'
ORDER BY A.REQUEST_DATE desc,D.SID,E.PIECE;

SELECT (SELECT sql_fulltext FROM v$sqlarea WHERE sql_id = ses.sql_id) SQL,(SELECT sql_fulltext FROM v$sqlarea WHERE sql_id = ses.prev_sql_id) "Previous SQL",
ses.CLIENT_IDENTIFIER,ses.module,ses.SID,ses.STATUS,ses.PROCESS,ses.serial#,ses.SQL_ID,ses.ACTION,--ses.SQL_EXEC_START,sysdate,sq.SQL_TEXT,sq.SQL_FULLTEXT,ses.OSUSER,ses.PROGRAM,ses.LOCKWAIT,
to_char(round(((sysdate-ses.SQL_EXEC_START)*24*60),2),'9G99999D99')||' Minutes |'||to_char(round(((sysdate-ses.SQL_EXEC_START)*24),2),'9G9999D99')||' Hours |'
    ||to_char(round(((sysdate-ses.SQL_EXEC_START)),2),'9G999D99')||' Days' "Run Time",ses.EVENT--,sq.EXECUTIONS,,ses.PREV_SQL_ID
FROM v$session ses,v$sqlarea sq WHERE sq. sql_id(+) = ses. sql_id and (SELECT sql_fulltext FROM v$sqlarea WHERE sql_id = ses.prev_sql_id) not like 'Select R.Rowid From Fnd_Concurrent_Requests R %'
--and ses.module ='JDBC Thin Client'--LIKE '%frm%'--e:ONT:frm:FNDRSRUN--e:PO:cp:RCVOLTM--e:BOM:wf:CSTAVGWF--SQL*Plus--JDBC Thin Client--FNDCPOPP--Disco10, ABBAS.KHAN:OM Inquiry--dis51usr.exe--
--ar.cusstd.busPurDetails.server.ArBusPurDetAM:R--rwrun@fre-srv-oa1.corsairhq.com (TNS V1-V3)--ReportingServicesService.exe--Microsoft.Mashup.Container.NetFX45.exe
--and client_identifier = 'ABBAS'
and STATUS='ACTIVE'
and (sq.SQL_TEXT IS NOT NULL OR ses.prev_sql_id IS NOT NULL)
--and ses.SID=758
--and ses.PROCESS='23193'
and ses.SQL_ID='ctz37vxg7mqgq'
ORDER BY SQL_EXEC_START desc
;