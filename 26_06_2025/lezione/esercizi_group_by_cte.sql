/*
	Usare il database biblioteca per eseguire queste query.
*/

/* Selezionare per ogni anno di pubblicazione (estrarlo da data_pub) il numero di libri pubblicati. */

select year(data_pub) as anno, count(*) as num_libri
from libro
group by anno
order by anno;

/* Visualizzare per ogni libro (non copia) quante volte è stato preso in prestito.
   Ordinare il risultato in ordine decrescente per numero di prestiti.
*/

select l.idl, l.titolo, count(*) num_prestiti
from libro l
join copia c on c.idl = l.idl
join prestito p on p.idc = c.idc
group by l.idl
order by num_prestiti desc;

/* Visualizzare per ogni autore il numero di libri che ha scritto. */

select a.ida, a.nome, a.cognome, count(*) num_libri
from autore a
join scrive s on s.ida = a.ida
group by a.ida, a.nome, a.cognome;

/* Visualizzare con un'unica query per ogni utente,
   il numero di prestiti attivi e il numero di prestiti conclusi.
   Ordinare il risultato in ordine alfabetico per cognome e nome. */

select u.num_tessera, u.cognome, u.nome,
count(data_restituzione) prestiti_conclusi,
count(*)-count(data_restituzione) prestiti_attivi
from utente u
join prestito p on p.num_tessera = u.num_tessera
group by u.num_tessera, u.cognome, u.nome
order by cognome, nome;


/* Visualizzare per ogni categoria il numero di libri che contiene. */


select c.cat_id, c.cat_nome, count(*) num_libri
from categoria c
join libro l on l.cat_id = c.cat_id
group by c.cat_id, c.cat_nome;

/* Selezionare nome e cognome dell'utente che ha fatto più prestiti. */

select u.num_tessera, u.nome, u.cognome, count(*) num_prestiti
from utente u
join prestito p on p.num_tessera = u.num_tessera
group by u.num_tessera, u.nome, u.cognome
having num_prestiti >= all(
select count(*)
from prestito
group by num_tessera);

/* Usare la funzione GROUP_CONCAT per visualizzare per ogni libro (mostrare id e titolo) l'elenco degli autori nel formato 
   nome1 cognome1, nome2 cognome2, ...,.
   nome e cognome possono essere concatenati prima con CONCAT.
   in un unico campo  */
   
   select l.idl, l.titolo, group_concat(concat(nome, ' ', cognome) separator ', ') autori 
   from libro l
   join scrive s on s.idl = l.idl
   join autore a on a.ida = s.ida
   group by l.idl, l.titolo
   having count(*) > 1
   order by l.idl;

/* Selezionare la categoria per cui ci sono più libri. */

select c.cat_id, c.cat_nome, count(*) num_libri
from categoria c
join libro l on c.cat_id = l.cat_id
group by c.cat_id, c.cat_nome
having num_libri >= all(
select count(*)
from libro
group by cat_id);

/* Selezionare l'anno (estraendolo da data_pub) in cui sono stati pubblicati più libri */

select year(data_pub)
from libro
group by year(data_pub)
having count(*) >= all (
select count(*)
from libro
group by year(data_pub)); -- prima la cerca nello scope locale poi se non lo trova lì la cerca nello scope globale, per questo non dà errore

/* Selezionare il libro scritto da più autori. */

select l.idl, l.titolo, count(*) num_autori
from libro l
join scrive s on s.idl = l.idl
group by l.idl, l.titolo
having num_autori >= all(
select count(*)
from scrive
group by idl);

/* Selezionare per ogni anno (estratto da data_prestito) il libro (non copia) che è stato preso in prestito
più volte. Eseguire la query senza viste/CTE. */

select year(data_prestito) anno, l.idl, l.titolo, count(p.idp) num_prestiti
from prestito p
join copia c on c.idc = p.idc
join libro l on l.idl = c.idl
group by anno, l.idl, l.titolo
having num_prestiti >= all(
select count(p1.idp)
from prestito p1
join copia c1 on c1.idc = p1.idc
where year(p1.data_prestito) = anno
group by c1.idl)
order by anno, num_prestiti desc;


/* Eseguire la query precedente con una CTE di supporto. */

with prestiti_libro_anno as( -- tabella temporanea che non viene salvata da nessuna parte
select year(p.data_prestito) anno, l.idl, l.titolo, count(p.idp) num_prestiti
from prestito p
join copia c on c.idc = p.idc
join libro l on l.idl = c.idl
group by anno, l.idl, l.titolo)
select*
from prestiti_libro_anno p
where num_prestiti >= all(
select num_prestiti
from prestiti_libro_anno p1
where p1.anno = p.anno);



/* Selezionare per ogni autore (visualizzare nome e cognome) il libro in cui compare che ha più autori.
   Considerare solo i libri con più autori.
   Usare prima una CTE che calcola per ogni libro da quanti autori è stato scritto. */
   
   
   explain with autori_libro as (
   select l.idl, l.titolo, count(ida) num_autori
   from libro l
   join scrive s on s.idl = l.idl
   group by l.idl, l.titolo
   having num_autori > 1 )
   select*
   from autore a
   join scrive s on s.ida = a.ida
   join autori_libro al on al.idl = s.idl
   where num_autori >= all(
   select num_autori
   from autori_libro al2
   join scrive s2 on s2.idl = al2.idl
   where s2.ida = a.ida)
   order by num_autori desc, a.cognome, a.nome;