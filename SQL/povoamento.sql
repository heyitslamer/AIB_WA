USE bd_urg;

insert into dim_proveniencia (DES_PROVENIENCIA, date)
	select DES_PROVENIENCIA,now() from urg_inform_geral
    group by DES_PROVENIENCIA;
    
insert into dim_local (DES_LOCAL, date)
	select DES_LOCAL,now() from urg_inform_geral
    group by DES_LOCAL;
    
    
insert into dim_idade (faixaEtaria, idade, grupo, date)(
select distinct
			CASE WHEN j.t < 10 THEN "00-10"
				when j.t < 20 then "10-20"
				when j.t < 30 then "20-30"
				when j.t < 40 then "30-40"
				when j.t < 50 then "40-50"
				when j.t < 60 then "50-60"
				when j.t < 70 then "60-70"
				when j.t < 80 then "70-80"
				when j.t < 90 then "80-90"
				when j.t < 100 then "90-100"
				else "Undef"
			END AS faixaEtaria,
            j.t as idade,
			CASE WHEN j.t < 10 THEN "Criança"
				WHEN j.t < 18 THEN "Adolescente"
				WHEN j.t < 40 THEN "Adulto"
				WHEN j.t < 60 THEN "Meia idade"
				else "Idoso"
			END AS grupo,
            now()
	from
	(SELECT TIMESTAMPDIFF(YEAR,idade.dta_nascimento,now()) as t,idade.dta_nascimento as n
        from ( select u.dta_nascimento from urg_inform_geral as u) as idade group by n) as j) ;
	
    insert into dim_genre (genero, date)
	select SEXO,now() from urg_inform_geral
    group by SEXO;
    
    insert into dim_especialidade (ALTA_DES_ESPECIALIDADE, date)
	select ALTA_DES_ESPECIALIDADE,now() from urg_inform_geral
    group by ALTA_DES_ESPECIALIDADE;
    
    
insert into dim_date ( day, month, year, datetime, date)
	select  distinct 
			day(STR_TO_DATE(DATAHORA_ADM, "%Y-%m-%d %H:%i:%s")), 
			month(STR_TO_DATE(DATAHORA_ADM, "%Y-%m-%d %H:%i:%s")), 
			year(STR_TO_DATE(DATAHORA_ADM, "%Y-%m-%d %H:%i:%s")),
            date(DATAHORA_ADM),
            now() from urg_inform_geral
            UNION
	select  distinct 
			day(STR_TO_DATE(DATAHORA_ALTA, "%Y-%m-%d %H:%i:%s")), 
			month(STR_TO_DATE(DATAHORA_ALTA, "%Y-%m-%d %H:%i:%s")), 
			year(STR_TO_DATE(DATAHORA_ALTA, "%Y-%m-%d %H:%i:%s")),
            date(DATAHORA_ALTA),
            now() from 
            urg_inform_geral;
            
insert into dim_time (hour, minutes, seconds, datetime, date)
	select  distinct 
            hour(STR_TO_DATE(DATAHORA_ADM, "%Y-%m-%d %H:%i:%s")),
            minute(STR_TO_DATE(DATAHORA_ADM, "%Y-%m-%d %H:%i:%s")),
            second(STR_TO_DATE(DATAHORA_ADM, "%Y-%m-%d %H:%i:%s")),
            time(DATAHORA_ADM),
            now() from urg_inform_geral
            UNION
	select  distinct 
            hour(STR_TO_DATE(DATAHORA_ALTA, "%Y-%m-%d %H:%i:%s")),
            minute(STR_TO_DATE(DATAHORA_ALTA, "%Y-%m-%d %H:%i:%s")),
            second(STR_TO_DATE(DATAHORA_ALTA, "%Y-%m-%d %H:%i:%s")),
            time(DATAHORA_ALTA),
            now() from 
            urg_inform_geral;
            
insert into dim_causa (DES_CAUSA, date)
	select DES_CAUSA,now() from urg_inform_geral
    group by DES_CAUSA;
    
insert into factos (id, DATA_ALTA, TIME_ALTA, DATA_ADM, TIME_ADM, IDADE, SEXO, DES_LOCAL, DES_PROVENIENCIA, DES_CAUSA, ALTA_DES_ESPECIALIDADE)
	select u.URG_EPISODIO,talta.iddatetime,ttalta.idtime,tadmi.iddatetime,ttadmi.idtime,i.ididade,g.idgenre,l.idlocal,p.idproveniencia,c.idcausa, e.idespecialidade from urg_inform_geral as u
		inner join dim_date as talta on date(u.DATAHORA_ALTA) = talta.datetime
        inner join dim_date as tadmi on date(u.DATAHORA_ADM) = tadmi.datetime
        inner join dim_time as ttalta on time(u.DATAHORA_ALTA) = ttalta.datetime
        inner join dim_time as ttadmi on time(u.DATAHORA_ADM) = ttadmi.datetime
        inner join dim_idade as i on TIMESTAMPDIFF(YEAR,u.DTA_NASCIMENTO,now()) = i.idade
        inner join dim_genre as g on u.SEXO = g.genero
        inner join dim_local as l on u.DES_LOCAL = l.DES_LOCAL
        inner join dim_proveniencia as p on u.DES_PROVENIENCIA = p.DES_PROVENIENCIA
        inner join dim_causa as c on u.DES_CAUSA = c.DES_CAUSA
        inner join dim_especialidade as e on u.ALTA_DES_ESPECIALIDADE = e.ALTA_DES_ESPECIALIDADE;
        