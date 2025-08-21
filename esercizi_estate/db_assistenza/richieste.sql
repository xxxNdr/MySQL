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

-- 4) Selezionare gli utenti che hanno aperto ticket per la categoria PEC

-- 5) Selezionare i tecnici (ruolo = tecnico) non hanno mai gestito ticket della categoria 'Informazioni'

-- 7) Selezionare i tecnici che hanno risolto solo ticket della categoria 'PEC'

-- 8*) Selezionare i tecnici che hanno sempre inviato una risposta in tutti i ticket che hanno chiuso

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