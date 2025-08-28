/**
Lo schema è il seguente:

Gli utenti possono essere amministratori, clienti o tecnici.
I clienti possono aprire ticket riguardo ad una categoria per chiedere aiuto riguardo a dei problemi,
un ticket appena inserito ha come stato 'aperto' e ha il valore NULL nel campo uid_tecnico, report_chiusura, timestamp_chiusura.

Un tecnico può prendere in carico un ticket, in questo caso il suo uid verrà inserito nel campo uid_tecnico
e lo stato del ticket passerà ad 'in_carico'. Si registra in timestamp_carico il momento in cui è stato preso in carico.
Quando il tecnico risolve un ticket, lo stato passa a 'chiuso' e vengono compilati i campi report_chiusura, timestamp_chiusura.

Relativamente ad un ticket, può avvenire uno scambio di messaggi tra il tecnico e l'utente che lo ha aperto che vengonos
salvati all'interno della relazione risposta.

utente (uid, email, password, nome, cognome, ruolo)
PK: uid
AK: email
Dominio ruolo: {amministratore, cliente, tecnico}

categoria (cid, nome, descrizione)
PK: cid

ticket (tid, titolo, messaggio, timestamp, timestamp_carico, report_chiusura, 
        timestamp_chiusura, uid_cliente, uid_tecnico, stato, cid)
PK: tid
Dominio stato: {aperto, in_carico, chiuso}
FK: cid REFERENCES categoria NOT NULL
FK: uid_cliente REFERENCES utente NOT NULL
FK: uid_tecnico REFERENCES tecnico

risposta(rid, tid, timestamp, messaggio, uid)
PK: rid
FK: tid REFERENCES ticket NOT NULL
FK: uid REFERENCES utente NOT NULL


*/


-- 1) Selezionare gli utenti che hanno aperto almeno un ticket che ha avuto delle risposte

select distinct u.*
from utente u
join ticket t on u.uid = t.uid_cliente
join risposta r on t.tid = r.tid
;

select *
from utente
where uid IN (
select t.uid_cliente
from ticket t, risposta r
where t.tid = r.tid
);

-- 2) Selezionare i clienti (ruolo = cliente) che non hanno mai aperto un ticket nella categoria 'Amministrazione'

select *
from utente u
where u.ruolo = 'cliente'
and not exists (
select *
from ticket t, categoria c
where t.cid = c.cid 
and t.uid_cliente = u.uid
and c.nome = 'amministrazione'
);

-- 3) Visualizzare i ticket che non hanno avuto risposte (nessun messaggio)
select t.*
from ticket t
left join risposta r on t.tid = r.tid
where r.rid is null;

/* INNER JOIN in SQL restituisce solo le righe che hanno corrispondenza
in entrambe le tabelle. Un INNER JOIN tra la tabella ticket e la tabella rispsota
sulla colonna tid mi mostrerebbe le righe dei ticket che hanno avuto almeno una risposta.
Entra in gioco LEFT OUTER JOIN perché restituisce tutte le righe della tabella di sinistra
ticket ANCHE SE NON ESISTONO corrispondenze nella tabella di destra risposta.
I ticket senza risposta saranno le colonne NULL nella tabella rispsota.
*/

-- 4) Selezionare gli utenti che hanno aperto ticket per la categoria PEC

select u.nome, u.cognome, u.uid
from utente u
join ticket t on t.uid_cliente = u.uid
join categoria c on t.cid = c.cid
where t.stato = 'aperto'
and c.nome = 'pec';

select nome, cognome, uid
from utente
where uid in (
	select uid_cliente
    from ticket
    where stato = 'aperto'
	and cid = (
        select cid
        from categoria
        where nome = 'pec'
	)
);

/* La query con INNER JOIN restituisce nel mio caso anche utenti che hanno più ticket aperti
della categoria pec, perché mostra una riga per ogni combinazione corrispondente tra le tabelle
ticket categoria e utente.
La query con IN invece mostra ogni utente una sola volta perché filtra quelli che hanno
ALMENO un ticket aperto nella categoria pec MA NON ripete ogni utente per ogni ticket.
Alla prima query quindi basta aggiungere DISTINCT per renderla uguale nel risultato alla seconda. */

-- 5) Selezionare i tecnici (ruolo = tecnico) non hanno mai gestito ticket della categoria 'Informazioni'

select nome, cognome, uid
from utente u
where not exists (
select *
from ticket t, categoria c
where t.uid_tecnico = u.uid
and t.cid = c.cid
and c.nome = 'informazioni'
);

-- 7) Selezionare i tecnici che hanno risolto solo ticket della categoria 'PEC'
select nome, cognome, uid
from utente u
where exists (
select *
from ticket t, categoria c
where t.uid_tecnico = u.uid
and t.cid = c.cid
and c.nome = 'pec'
);
/*
questa query seleziona tutti i tecnici che hanno risolto almeno un ticket della
 categoria pec, ma non esclude quelli che hanno risolto ticket di altra categoria
 */
 

select nome, cognome, uid
from utente
where ruolo = 'tecnico'
and uid in (
select uid_tecnico
from ticket
where report_chiusura is not null
and cid = (
select cid from categoria where nome = 'pec'
))
and uid not in (
select uid_tecnico
from ticket
where report_chiusura is not null
and cid != (
select cid from categoria where nome = 'pec'
));

-- la parte con IN seleziona i tecnici che hanno risolto almeno un ticket di tipo pec
-- la parte con NOT IN esclude i tecnici che hanno risolto ticket di altre categorie

select u.nome, u.cognome, u.uid
-- seleziono il nome cognome e id utente
from utente u
-- dalla tabella utente con alias u
join ticket t on u.uid = t.uid_tecnico
-- faccio join con le tabelle ticket e utente dove uid utente corrisponde a uid_tecnico ticket
join categoria c on t.cid = c.cid
-- faccio join con le tabelle categoria e ticket dove unisco i ticket alla categoria di appartenenza tramite la colonna cid
where u.ruolo = 'tecnico'
-- applico il filtro sul ruolo dell'utente che deve essere 'tecnico'
and report_chiusura is not null
-- aggiungo un secondo filtro per cui il report_chiusura non è nullo così sono certo che il ticket è stato chiuso
and c.nome = 'pec'
-- aggiungo un altro filtro sul nome della categoria che deve essere 'pec'
and not exists (
/*
il NOT EXISTS verifica che non esistano ticket chiusi da tecnici diversi dalla categoria 'pec'
grazie alla combinazione con c2.nome != 'pec'
Restituisce TRUE se la subquery non trova righe; controlla l'assenza di certi dati
*/
select *
-- seleziono tutti i campi
from ticket t2
-- dalla tabella ticket con alias t2 per differenziarla da ticket t che è la query padre
join categoria c2 on t2.cid = c2.cid
-- faccio il join tra categoria e ticket sulla colonna cid, così conosco la categoria di ciascun ticket
where t2.uid_tecnico = u.uid
-- cerco solo il ticket il cui tecnico (uid_tecnico) è uguale all'utente (u.uid) della query principale
-- la subquery cerca il ticket del tecnico considerato nella query principale 
and t2.report_chiusura is not null
-- continuando a cercare solo i report chiusi
and c2.nome != 'pec')
-- che NON appartengano alla categoria pec
group by u.nome, u.cognome, u.uid;
/*
Evita duplicati. Più righe della tabella ticket possono corrispondere allo stesso tecnico perciò
raggruppando per i campi identificativi del tecnico la query restituisce una sola riga
per tecnico anche se ha più ticket chiusi nella categoria 'pec'
Tecnica per rendere l'elenco finale univoco e più leggibile
*/ 


-- 8*) Selezionare i tecnici che hanno sempre inviato una risposta in tutti i ticket che hanno chiuso

select distinct u.nome, u.cognome, u.uid
from utente u
join ticket t on u.uid = t.uid_tecnico
join risposta r on t.tid = r.tid
where u.ruolo = 'tecnico'
and r.messaggio is not null
and report_chiusura is not null;

select u.nome, u.cognome, u.uid
from utente u
join ticket t on u.uid = t.uid_tecnico
join risposta r on t.tid = r.tid
where u.ruolo = 'tecnico'
and r.messaggio is not null
and report_chiusura is not null
group by u.nome, u.cognome, u.uid;

/* Queste due query danno lo stesso risultato ma non rispettano la consegna perché:
- selezionano i tecnici che hanno dato almeno una risposta in qualche ticket chiuso da loro
NON verifica che abbiano risposto a tutti i ticket chiusi!
In poche parole basta che un tecnico abbia dato una risposta a un singolo ticket chiuso
per essere incluso nel risultato.
L'obbiettivo invece è selezionare SOLO i tecnici che hanno SEMPRE risposto a tutti i loro ticket chiusi
*/

select u.nome, u.cognome, u.uid
from utente u
where u.ruolo = 'tecnico'
and not exists (
select *
from ticket t
where t.uid_tecnico = u.uid
and report_chiusura is not null
and not exists (
select *
from risposta r
where t.tid = r.tid
and r.uid = u.uid
-- questo filtro è molto importante per specificare che l'autore del messaggio sia proprio quel tecnico che ha chiuso il ticket
and r.messaggio is not null
));

-- 9) Visualizzare il numero di ticket aperti, chiusi e in carico.
-- Il risultato deve essere visualizzato in un'unica query.

-- 10) Visualizzare il tempo medio di attesa per la presa in carico di un ticket

-- 11) Visualizzare per ogni tecnico (nome e cognome) il numero di ticket che ha preso in carico e che ha chiuso.
-- Usare una o più CTE per eseguire il calcolo

-- 12) Visualizzare il numero di ticket presenti per ogni categoria.

-- 13) Selezionare il cliente che ha aperto più ticket

-- 14) Selezionare nome e cognome del tecnico che ha chiuso più ticket

-- 15) Selezionare per ogni mese ed anno il nome e il cognome del tecnico che ha chiuso più ticket
-- ordinando il risultato per anno e mese

-- 16) Selezionare per ogni tecnico il tempo medio di completamento di un ticket (tempo intercorso da quando ha preso in carico un ticket
-- a quando lo ha chiuso)

-- 17) Selezionare il tecnico con il tempo medio di chiusura minore (aiutarsi con una CTE)

-- 18) Selezionare i tecnici che nel 2021 hanno chiuso più ticket rispetto al 2020