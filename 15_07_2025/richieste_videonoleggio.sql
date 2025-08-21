-- 1) Eseguire le seguenti modifiche al database
-- a) Aggiungere il vincolo che il prezzo un noleggio deve essere maggiore di 0. 

alter table noleggio
add constraint prezzoPos check (prezzo > 0);

describe noleggio;
show create table noleggio;
insert into noleggio values (2000,1,1,1,now(),0);
-- b) Aggiungere il vincolo che un cliente può noleggiare lo stesso film al massimo una volta al giorno (non serve un trigger!).

alter table noleggio
add constraint film1giorno unique (id_cliente, id_film, data_noleggio);
show create table noleggio;
insert into noleggio values (default, '1','559','40','2017-09-28','6');
-- c) Aggiungere l'attributo intero negozio_premium alla tabella dei negozi. Impostare il valore dell'attributo a 1 per tutti i negozi che hanno effettuato noleggi di un importo complessivo superiore a 4000 e a 0 per tutti gli altri. 
alter table negozio add negozio_premium int not null default 0;
describe noleggio;
show create table noleggio;
select * from negozio;

SET SQL_SAFE_UPDATES = 0;
-- questo comando va a verificare che nella query ci sia effettivamente una where così da farla funzionare

update negozio set negozio_premium = 1
where id_negozio in(
select id_negozio
from noleggio
group by id_negozio
having sum(prezzo) > 4000);


-- 2) Selezionare i clienti di Modena che si sono registrati nel 2014.
select cognome, nome
from cliente
where citta_residenza = 'modena'
and year(data_registrazione) = 2014;
-- oppure: and data_registrazione between '2024-1-1' and '2024-12-31';
-- oppure:  and data_registazione like '2014%';
-- 3) Quanti clienti ci sono nel database?
select count(*) num_clienti
from cliente;
-- count(*) conta il numero di righe,
-- count(attributo) conta i valori non nulli contenuto nell'attributo
-- 4) Quanti registi diversi ci sono nel database?
select sum(table_rows)
from information_schema.tables
where table_schema = database();
-- 5) Qual è il costo minimo, medio e massimo di un noleggio?
select
min(prezzo) min,
avg(prezzo) med,
max(prezzo) max
from noleggio;

-- 6) Selezionare i dati dei clienti che hanno noleggiato almeno un film nel 2018.
select c.*
from cliente c
join noleggio n on n.id_cliente = c.id_cliente
where year(data_noleggio) = 2018;

select c.id_cliente, c.cognome, c.nome, count(n.id_film) film_noleggiati
from cliente c join noleggio n on c.id_cliente = n.id_cliente
where year(data_noleggio) = 2018
group by c.id_cliente, c.cognome, c.nome
order by film_noleggiati desc;

select *
from cliente
where id_cliente in(
select id_cliente
from noleggio
where year(data_noleggio) = 2018);

select *
from cliente
where id_cliente = any(
select id_cliente
from noleggio
where year(data_noleggio) = 2018);

-- 7) Selezionare i negozi di Modena che hanno noleggiato film a clienti residenti a Bologna.
-- Per ognuno di questi selezionare il nome del negozio, la data ed il prezzo del noleggio.
-- Ordinare il risultato per il nome del negozio e per la data del noleggio in ordine cronologico inverso.
select ne.nome, nol.data_noleggio, nol.prezzo
from noleggio nol
join negozio ne on ne.id_negozio = nol.id_negozio
join cliente c on c.id_cliente = nol.id_cliente
where c.citta_residenza = 'bologna'
and ne.citta = 'modena'
order by ne.nome, nol.data_noleggio desc;


-- 8) Selezionare i dati dei clienti che hanno noleggiato almeno un film di Steven Spielberg.
select *
from cliente
where id_cliente in(
select id_cliente
from noleggio n
join film f on f.id_film = n.id_film
where f.regista = 'steven spielberg');

select *
from cliente
where id_cliente in(
select n.id_cliente
from noleggio n, film f
where n.id_film = f.id_film
and f.regista = 'steven spielberg');

-- 9) Selezionare i clienti che hanno sempre speso almeno 12€ per un noleggio.
select c.*
from cliente c
where not exists(
select *
from noleggio n
where n.id_cliente = c.id_cliente
and n.prezzo < 12);

select c.*,
(
select n.prezzo
from noleggio n
where n.id_cliente = c.id_cliente
order by n.data_noleggio desc
limit 1
) ultimo_prezzo
from cliente c
where not exists(
select*
from noleggio n
where n.id_cliente = c.id_cliente
and n.prezzo < 12);

select distinct c.*
from cliente c
join noleggio n on c.id_cliente = n.id_cliente
where c.id_cliente not in (
select id_cliente
from noleggio
where prezzo < 12);


select distinct c.*
from cliente c
join noleggio n on c.id_cliente = n.id_cliente
where 12 <= all(
select prezzo
from noleggio n1
where n1.id_cliente = c.id_cliente);

-- 10) Selezionare (se presenti) i clienti che non hanno mai noleggiato film da negozi di Modena. 

select c.nome, c.cognome
from cliente c
where id_cliente not in(
select id_cliente
from noleggio n
join negozio ne on ne.id_negozio = n.id_negozio
where ne.citta = 'modena');

-- 11) Selezionare (se presenti) i negozi che non hanno mai noleggiato film di Quentin Tarantino nel 2018.

select * 
from negozio
where id_negozio not in(
select id_negozio
from noleggio n
join film f on f.id_film = n.id_film
where year (data_noleggio) = 2018
and f.regista = 'quentin tarantino');
-- sottraggo dall'insieme negozio l'insieme negozio  che NON HANNO (not in) noleggiato (select id negozio from noleggio) film (join film on...) di quentin tarantino nel 2018
-- (where f.regista = quentin and year(data noleggio)

select *
from negozio except
select ne.*
from negozio ne
join noleggio n on n.id_negozio = ne.id_negozio
join film f on f.id_film = n.id_film
where year(n.data_noleggio) = 2018
and f.regista = 'quentin tarantino';


-- 12) Selezionare il nome ed il cognome del cliente/i che ha noleggiato il film meno costoso tra tutti i film noleggiati (inteso come prezzo di noleggio). 

select distinct nome, cognome
from cliente c
join noleggio n on n.id_cliente = c.id_cliente
where prezzo <= all(
select prezzo
from noleggio
);

-- 13) Selezionare per ogni film il numero di volte che è stato noleggiato.
-- chiede di calcolare delle metriche aggregate, non più globali come prima ma sono per ogni gruppo di qualcosa, film, cliente, negozio, anno.
select f.nome, f.id_film, f.anno, f.regista, count(n.id_film) num_noleggi
from film f
join noleggio n on n.id_film = f.id_film
group by f.nome, f.id_film, f.anno, f.regista
order by f.id_film;


-- 14) Selezionare, per ogni cliente, il numero totale di negozi diversi da cui ha noleggiato dei film ed il numero totale di film noleggiati,
-- considerando solo clienti che hanno noleggiato un numero minimo di 7 film diversi. 

select c.id_cliente, c.cognome, c.nome, count(n.id_negozio) num_negozi, count(n.id_film) tot_noleggi
from cliente c
join noleggio n on n.id_cliente = c.id_cliente
group by c.id_cliente, c.cognome, c.nome
having count(distinct n.id_film) >= 7
order by tot_noleggi;

-- 15) Selezionare per ogni negozio e anno, il numero di noleggi effettuati, il totale incassato,
-- il numero distinto di film noleggiati e il numero distinto di clienti che si sono rivolti a quel negozio.

select ne.id_negozio, ne.nome, year(n.data_noleggio) anno, count(*) num_noleggi, sum(n.prezzo) incasso_totale,
count(distinct n.id_film) film_distinti,
count(distinct n.id_cliente) clienti_distinti
from negozio ne
join noleggio n on n.id_negozio = ne.id_negozio
group by ne.id_negozio, ne.nome, anno
order by incasso_totale desc;



-- 16) Selezionare per ogni cliente il numero di noleggi fatti. Visualizzare 0 se un cliente non ha fatto alcun noleggio.
-- Ordinare il risultato in ordine crescente per numero di noleggi.

select c.id_cliente, c.nome, c.cognome, count(n.id_film) noleggi
from cliente c
left join noleggio n on n.id_cliente = c.id_cliente
group by c.id_cliente, c.nome, c.cognome
order by noleggi;
-- se faccio count(*) non escono i risultati
-- un normale join mi avrebbe restituito solo i clienti che hanno fatto almeno un noleggio, 

-- 17) Selezionare il nome ed il cognome del cliente che ha effettuato il maggiore numero di noleggi.

select c.id_cliente, c.nome, c.cognome, count(id_noleggio) num_noleggi
from cliente c
join noleggio n on n.id_cliente = c.id_cliente
group by c.id_cliente, c.nome, c.cognome
having num_noleggi >= all(
select count(id_noleggio)
from noleggio
group by id_cliente);

-- 18) Selezionare la città in cui è stato effettuato l'incasso maggiore in noleggi.
with incassi as(
select citta, sum(n.prezzo) incasso
from negozio ne
join noleggio n on n.id_negozio = ne.id_negozio
group by citta
)
select *
from incassi
where incasso = (
select max(incasso) from incassi
);
-- 19) Selezionare il film più noleggiato.

-- 20) Selezionare per ogni cliente l'anno in cui ha noleggiato più film. 
-- 21) Selezionare per ogni negozio e anno il film più noleggiato. Ordinare il risultato per negozio e anno.
-- 20 e 21 richiedono la correlazione

-- 22) Selezionare il regista i cui film hanno il prezzo di noleggio medio più alto.
-- Calcolare con una vista/CTE il prezzo di noleggio medio per regista e poi selezionare quello più alto.

-- 23) Selezionare il negozio che ha l'incasso medio annuale più alto.
-- Calcolare con una vista/CTE prima l'incasso medio annuale di ogni negozio. Poi calcolare per ogni negozio l'incasso medio e prendere quello più alto.
-- 
-- 24) Definire un trigger che impedisca ad un cliente di noleggiare più di 3 film nella stessa data.
