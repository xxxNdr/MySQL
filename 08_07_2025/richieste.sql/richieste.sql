/*
cantina(idc, nome, provincia)

vino(idv, nome, tipo)

produzione(idc, idv, anno, bottiglie)
PK: idc, idv, anno
FK: idc REFERENCES cantina
FK: idv REFERENCES vino

cliente(PIVA, nominativo)
PK: PIVA

vendita(id, idc, idv, anno, bottiglie, datav, PIVA)
PK: id
FK: idc, idv, anno REFERENCES produzione NOT NULL
FK: PIVA REFERENCES cliente NOT NULL
*/

-- 1) Selezionare le cantine della provincia di Modena che producono vini rossi (utilizzare l'operatore IN)
select *
from cantina c
where provincia = 'modena'
and idc in (
select idc
from produzione p
join vino v on v.idv = p.idv
where tipo = 'rosso');

-- 1bis) Si può riscrivere la query precedente utilizzando il JOIN?

select distinct c.*, v.nome
from cantina c 
join produzione p on p.idc = c.idc
join vino v on v.idv = p.idv
where tipo = 'rosso' and provincia = 'modena';

-- 1ter) Riscrivere la query 2 utilizzando l'operatore EXISTS.

select *
from cantina c where provincia = 'modena'
and exists(
select *
from produzione p
join vino v on v.idv = p.idv
where tipo = 'rosso'
and p.idc = c.idc);
-- 2) Selezionare le cantine della provincia di Modena che NON producono vini rossi (utilizzare l'operatore NOT IN); 

select *
from cantina c
where provincia = 'modena' and idc not in(
select idc
from produzione p
join vino v on v.idv = p.idv
where v.tipo = 'rosso'
);
-- 2bis) Si può riscrivere la query 3 utilizzando il JOIN?

select *
from cantina c
where provincia = 'modena' and
not exists(
select*
from produzione p
join vino v on v.idv = p.idv
where v.tipo = 'rosso'
and p.idc = c.idc
);
-- 2ter) Riscrivere la query precedente utilizzando l'operatore NOT EXISTS.
-- 3) Selezionare, per ogni cantina e vino, l'anno di produzione con la vendita unica più alta (ossia la vendita con il maggior numero di bottiglie vendute).

select c.nome cantina, v.nome vino, anno, bottiglie
from cantina c
join vendita ve on ve.idc = ve.idc
join vino v on v.idv = ve.idv
where bottiglie >= all(
select bottiglie
from vendita ve2
where ve2.idc = c.idc
and ve2.idv = v.idv)
order by c.nome, v.nome;
-- 4) Selezionare i vini che hanno SEMPRE avuto vendite superiori alle 10000 bottiglie per ogni annualità di produzione.
select *
from vino
where idv not in(
select idv
from produzione
group by idv, anno
having sum(bottiglie) < 10000);
-- 5) Selezionare il nome della cantina, il nome del vino e l'anno con il maggiore numero di litri bottiglie vendute.

select c.nome nome_c, vi.nome nomev, anno, sum(bottiglie) tot
from vendita v
join vino vi on vi.idv = v.idv
join cantina c on c.idc = v.idc
group by c.idc, c.nome, vi.idv, vi.nome, anno
having sum(bottiglie) >= all(
select  sum(bottiglie)
from vendita
group by idc, idv, anno);

-- 6) Selezionare per ogni vino il numero di cantine che lo produce.

select v.idv, v.nome, count(*) numero_cantine
from vino v
join produzione p on p.idv = v.idv
group by v.idv, v.nome;

-- 7) Selezionare i vini prodotti da almeno 4 cantine.

select v.idv, v.nome, count(*) numero_cantine
from vino v
join produzione p on p.idv = v.idv
group by v.idv, v.nome
having numero_cantine >= 4
order by numero_cantine desc;

-- 8) Selezionare il vino prodotto da più cantine.

select v.idv, v.nome, count(*) numero_cantine
from vino v
join produzione p on p.idv = v.idv
group by v.idv, v.nome
having numero_cantine >= all(
select count(*)
from produzione
group by idv);

-- 9) Selezionare per ogni vino e cantina la quantità mensile venduta in media, ordinare il risultato in modo descrescente per la vendita media.

select idv, idc, month(datav) mese, avg(bottiglie) qta_media
from vendita
group by idv, idc, mese
order by qta_media desc;

-- 10) Selezionare per ogni cantina la quantità totale di vino venduta.

select idc, sum(bottiglie)
from vendita
group by idc;

-- 11) Selezionare per ogni cantina ed anno la quantità totale di vino venduta. Ordinare il risultato per cantina, in modo descrescente rispetto alla quantità venduta.

select idc, year(datav) anno, sum(bottiglie) tot
from vendita
group by idc, anno;

-- 12) Selezionare per ogni cantina l'anno in cui ha venduto più vino.

select v.idc, year(datav) anno_vendita, sum(bottiglie) tot
from vendita v
group by v.idc, anno_vendita
having tot >= all(
select sum(bottiglie)
from vendita v2
where v2.idc = v.idc
group by year(v2.datav));

-- 12bis) Eseguire la query precedente utilizzando una Common Table Expression (CTE) che contiene per ogni cantina la quantità di vino venduta per anno.

with vendite_annue as (select idc, year(datav) anno_vendita, sum(bottiglie) tot
from vendita 
group by idc, anno_vendita)
select *
from vendite_annue v
where tot >= all(
select tot
from vnedite_annue v2
where v2.idc = v.idc);

-- 13) Selezionare per ogni provincia, l'anno in cui è stato prodotto meno vino bianco. Ordinare il risultato per le quantità prodotte.

select provincia, anno, sum(bottiglie) tot
from cantina c
join produzione p on p.idc = c.idc
join vino v on v.idv = p.idv
where tipo = 'bianco'
group by provincia, anno
having tot <= all(
select sum(bottiglie)
from cantina c1
join produzione p1 on p1.idc = c1.idc
join vino v1 on v1.idv = p1.idv
where v1.tipo = 'bianco'
and c1.provincia = c.provincia
group by anno);

-- 13bis) Eseguire la query precedente utilizzando una CTE che crei per ogni provincia/anno la quantità di vino bianco venduta.

with prod_vino_bianco as (
select provincia, anno, sum(bottiglie) tot
from cantina c
join produzione p on p.idc = c.idc
join vino v on v.idv = p.idv
where tipo = 'bianco'
group by provincia, anno
)
select*
from prod_vino_bianco p1
where p1.tot = (
select min(tot)
from prod_vino_bianco p2
where p2.provincia = p1.provincia);
-- 14) Selezionare le cantine che producono solo vini di tipo rose.

select*
from cantina
where idc not in(
select idc
from produzione p 
join vino v on v.idv = p.idv
where v.tipo != 'rose');

-- 15) Selezionare i nomi delle cantine che nel 2010 hanno prodotto più vino rispetto al 2009

select c.idc, nome, sum(bottiglie)
from cantina c
join produzione p on p.idc = c.idc
where anno = 2010
group by c.idc, nome
having sum(bottiglie) >(
select sum(bottiglie)
from produzione p2
where anno = 2009
and p2.idc = c.idc);


with produzione_2009 as (
select idc, sum(bottiglie) p2009
from produzione
where anno = 2009
group by idc
),
produzione_2010 as (
select idc, sum(bottiglie) p2010
from produzione
where anno = 2010
group by idc
)
select *
from produzione_2009 p
join produzione_20110 p2 on p2.idc = p.idc
where p2010 >p2009;