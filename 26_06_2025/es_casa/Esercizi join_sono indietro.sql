-- Utilizzare il database biblioteca

use biblioteca;

-- Visualizzare i dati dei libri che appartengono direttamente alla categoria 'Science'
select *
from libro
join categoria
where cat_nome = 'science';

-- Ordinare il risultato in ordine alfabetico per titolo del libro
select*
from libro
join categoria
where cat_nome = 'science'
order by titolo;

-- Visualizzare i prestiti attivi (data fine è nulla se il prestito è attivo
select*
from prestito p
join copia c on c.idc = p.idc
join libro l on l.idl = c.idl
join utente u on u.num_tessera = p.num_tessera
where data_restituzione is null;

-- Mostrare i dati dell'utente che ha il libro, i dati della copia e del libro in prestito. /*paper rose

select titolo
from libro
join prestito
join utente;

select *
from libro l
join copia c on c.idl = l.idl
join prestito p on p.idc = c.idc
join utente u on u.num_tessera = p.num_tessera 
where l.titolo = 'california roll'
and p.data_restituzione is null;

-- Visualizzare i dati delle sottocategorie che hanno come categoria principale 'Science'

describe categoria;

select c.cat_nome as categoria, coalesce(padre.cat_nome, '') categoria_padre
from categoria c
left join categoria padre on c.main_cat_id = padre.cat_id
where padre.cat_nome = 'science';

select c.cat_nome as categoria, padre.cat_nome as categoria_padre
from categoria c
left join categoria padre on c.main_cat_id = padre.cat_id
where padre.cat_nome = 'science';

select
c.cat_nome, coalesce(padre.cat_nome, '') as categoria_padre
from categoria c
left join categoria padre on c.main_cat_id = padre.cat_id and padre.cat_nome = 'science';

-- Visualizzare i dati dei libri scritti da Stephen King

select *
from libro l
join scrive s on s.idl = l.idl
join autore a on a.ida = s.ida
where a.nome = 'stephen' and a.cognome = 'king';

-- Visualizzare i nomi degli utenti che nel 2024 hanno preso in prestito libri scritti da John Allan

select*
from utente u
join prestito p on p.num_tessera = u.num_tessera
join copia c on c.idc = p.idc
join libro l on l.idl = c.idl;

select u.nome and u.cognome
from utente u
join prestito p on p.num_tessera = u.num_tessera
join copia c on c.idc = p.idc
join libro l on l.idl = c.idl
join scrive s on s.idl = l.idl
join autore a on a.ida = s.ida
where year(data_prestito) = 2024 and a.nome = 'stephen' and a.cognome = 'king';

