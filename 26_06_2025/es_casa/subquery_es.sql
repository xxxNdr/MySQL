-- ------------------------------------------------------------------
-- Utilizzare l'operatore ANY | ALL per eseguire le seguenti query --
-- ------------------------------------------------------------------
-- 1) Selezionare i dipendenti (nome e cognome) che hanno avuto almeno uno 
    -- stipendio maggiore di 100000
	describe dipendente;
    describe ruolo;
    
    select distinct dip_id
    from stipendio
    where dip_id in (
    select  dip_id
    from dipendente
    where stipendio > 100000 );
    
    select nome, cognome
    from dipendente
    where dip_id in (
    select dip_id
    from stipendio
    where stipendio > 100000 );
    
	-- Si può riscrivere la query con il JOIN?
    select distinct d.nome, d.cognome
    from stipendio s
    join dipendente d on d.dip_id = s.dip_id
    where stipendio > 100000
    order by stipendio desc;

-- 2) Selezionare il codice dei dipendenti che hanno avuto lo stipendio maggiore di 
    -- tutti gli stipendi del dipendente numero 10100
    
       select nome, cognome
    from dipendente
    where dip_id in (
    select dip_id
    from stipendio
    where stipendio > all (
    select stipendio
    from stipendio
    where dip_id = 10100));
    
	-- E' possibile riscrivere la stessa query utilizzando l'operatore di JOIN? 
  select distinct d.dip_id
  from dipendente d
  join stipendio s on s.dip_id = d.dip_id
  where stipendio > all (
  select stipendio
  from stipendio
  where dip_id = 10100);
    
	-- In caso affermativo, riscrivere l'interrogazione utilizzando 
	-- l'operatore di JOIN ed evidenziare le differenze. 
    SELECT DISTINCT d.dip_id
FROM dipendente d
JOIN stipendio s1 ON d.dip_id = s1.dip_id
LEFT JOIN stipendio s2 ON s2.dip_id = 10100
GROUP BY d.dip_id, s1.importo
HAVING s1.importo > MAX(s2.importo);

select distinct d.dip_id
from dipendente d
join stipendio s1 on s1.dip_id = d.dip_id
left join stipendio s2 on s2.dip_id = 10100
group by d.dip_id, s1.stipendio
having s1.stipendio > max(s2.stipendio);
 


-- 3) Selezionare, per ogni dipendente, il nome, il cognome e lo stipendio massimo avuto 
select nome, cognome, dip_id,
(
select max(stipendio)
from stipendio
where dip_id = d.dip_id
) as stipendio_massimo
from dipendente d
order by stipendio_massimo desc;

-- 4) Selezionare il dipendente più giovane di tutti
select data_nascita, nome, cognome
from dipendente
order by data_nascita desc
limit 1;

select nome, cognome, data_nascita
from dipendente
where data_nascita = (
select max(data_nascita)
from dipendente);

-- -----------------------------------------------------------------
-- Utilizzare l'operatore [NOT] IN per svolgere le seguenti query --
-- -----------------------------------------------------------------

-- 5) Selezionare i dipendenti che hanno avuto il ruolo di ingegnere 
-- (la parola "ingegnere" deve essere presente nell'attributo "titolo")

select titolo
from ruolo
where titolo = 'ingegnere';

/*select nome, cognome
from dipendente
where 'ingegnere' in (
select titolo
from ruolo
where titolo = 'ingegnere');*/

select nome, cognome
from dipendente
where dip_id in (
select dip_id
from ruolo
where titolo = 'ingegnere');

--
-- 5bis) Si può fare con il join? Se sì, riscrivere la query
select d.nome, d.cognome
from dipendente d
join ruolo r on r.dip_id = d.dip_id
where titolo like 'ingegnere';

--
-- 6) Selezionare i dipendenti che NON hanno mai ricevuto
-- uno stipendio maggiore di 50000
select nome, cognome
from dipendente
where dip_id not in (
select dip_id
from stipendio
where stipendio > 50000);

-- 6bis) Domanda: E' possibile riscrivere la query precedente usando 
-- l'operatore JOIN senza una query innestata? 
select distinct d.nome, d.cognome, s.stipendio
from dipendente d
join stipendio s on s.dip_id = d.dip_id
where s.stipendio < 50000
order by s.stipendio desc;

describe stipendio;

select d.nome, d.cognome, max(stipendio) as stipendio_massimo
from dipendente d
join stipendio s on s.dip_id = d.dip_id
where stipendio < 50000
group by d.dip_id, d.nome, d.cognome
order by stipendio_massimo;



-- Utilizzare l'operatore [NOT] EXISTS					--
-- -------------------------------------------------------

-- 
-- 7) Selezionare il nome ed il cognome dei dipendenti che hanno avuto uno 
-- stipendio maggiore di 50.000 

/* ERRATA
select nome, cognome, dip_id
from dipendente
where  exists (
select nome, cognome, dip_id
from stipendio
where stipendio > 50000); */

select nome, cognome
from dipendente d
where exists (
select *
from stipendio s
where d.dip_id = s.dip_id and stipendio > 50000 );

-- 7 bis) Si può rifare la query con l'operatore JOIN?

select distinct d.nome, d.cognome
from dipendente d
join stipendio s on s.dip_id = d.dip_id
where stipendio > 50000;
--
-- 8) Selezionare gli stipendi dei dipendenti che NON hanno MAI fatto parte dallo Staff
describe ruolo;

select *
from ruolo;

titolo = 'staff'

select stipendio
from stipendio
where dip_id not in (
select dip_id
from dipendente
where dip_id not in (
select dip_id
from ruolo
where titolo = 'staff'));

select distinct s.stipendio
from stipendio s
where not exists (
select *
from ruolo r
where r.dip_id = s.dip_id
and r.titolo = 'staff');

select distinct nome, cognome
from dipendente d
where exists (
select *
from stipendio s
where s.dip_id = d.dip_id )
and not exists (
select *
from ruolo r
where r.dip_id = d.dip_id
and titolo = 'staff');

select distinct
(select nome
from dipendente d
where d.dip_id = s.dip_id) as nome,
(select cognome
from dipendente d
where d.dip_id = s.dip_id) as cognome,
(select r.titolo
from ruolo r 
where r.dip_id = s.dip_id and r.titolo  != 'staff'
limit 1) as titolo
from stipendio s
where exists(
select*
from ruolo r
where r.dip_id = s.dip_id and r.titolo != 'staff');



-- 8) bis Si può rifare la query con l'operatore JOIN?
select distinct d.nome, d.cognome, r.titolo
from stipendio s
join dipendente d on d.dip_id = s.dip_id
join ruolo r on r.dip_id = s.dip_id
where r.titolo != 'staff';

-- 9) Selezionare i dipendenti che NON hanno MAI fatto parte dallo Staff
select d.nome, d.cognome
from dipendente d
where d.dip_id not in (
select r.dip_id
from ruolo r
where titolo = 'staff')
order by d.cognome;

select d.nome, d.cognome
from dipendente d
where not exists (
select *
from ruolo r
where r.dip_id = d.dip_id
and titolo = 'staff')
order by d.cognome;

-- e che hanno avuto lo stipendio maggiore di 50.000
select d.nome, d.cognome, (
select max(stipendio)
from stipendio s
where s.dip_id = d.dip_id) as stipendio_massimo 
from dipendente d
where not exists (
select *
from ruolo r
where r.dip_id = d.dip_id
and r.titolo = 'staff')
and exists (
select *
from stipendio s
where s.dip_id = d.dip_id
and s.stipendio > 50000)
order by d.cognome;

-- 9bis) Selezionare i dipendenti che NON hanno MAI fatto parte dallo Staff e
-- che NON hanno MAI avuto lo stipendio maggiore di 50000 
select d.nome, d.cognome, (
select max(stipendio)
from stipendio s
where d.dip_id = d.dip_id) as stipendio_massimo
from dipendente d
where not exists (
select *
from ruolo r
where r.dip_id = d.dip_id and r.titolo = 'staff')
and not exists (
select*
from stipendio s
where s.dip_id = d.dip_id and stipendio >50000)
order by stipendio_massimo desc;

-- ------------------------------------------------------------------------------------------------------------------- 	
-- 10) Scrivere la query seguente usando (se possibile) 
-- ognuno dei tre operatori insiemistici (IN|ALL, [NOT] IN, [NOT] EXISTS)
-- Selezionare il codice del dipendente che ha avuto lo stipendio più 
-- alto di tutti gli altri dipendenti. 

select r.dip_id,
( select max(stipendio)
from stipendio s
where s.dip_id = r.dip_id) as stipendio_massimo
from ruolo r
where exists(
select*
from stipendio s
where s.dip_id = r.dip_id and s.stipendio >50000 )
and exists (
select *
from dipendente d
where d.dip_id = r.dip_id)
limit 1;
