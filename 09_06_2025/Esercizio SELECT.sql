-- Utilizzare il database biblioteca
USE biblioteca;


SELECT nome, cognome, datan
FROM utente
ORDER BY datan DESC, cognome ASC, nome;

SELECT u.nome, u.cognome AS 'c'
FROM utente u;

SELECT *
FROM utente
WHERE datan >= '1/1/1988' AND datan <= '31/12/1988';

SELECT DISTINCT nome
FROM utente
ORDER BY nome;

SELECT *
FROM utente
ORDER BY cognome, nome
LIMIT 90, 20;

SELECT*
FROM(
SELECT *
FROM utente
LIMIT 20) AS tmp
ORDER BY cognome, nome;

SELECT *
FROM utente
WHERE YEAR(datan) = 1990;

SELECT*
FROM utente
WHERE MONTH(datan) = 2
AND YEAR(datan) = 1980;

SELECT*
FROM utente
WHERE nome LIKE 'j%';

SELECT DISTINCT cognome
FROM utente
WHERE cognome LIKE '_____';

SELECT COUNT(*)
FROM utente;

SELECT COUNT(DISTINCT nome) AS num_nomi, COUNT(DISTINCT cognome) AS num_cognomi
FROM utente;

SELECT COUNT(DISTINCT YEAR(datan))
FROM utente;

SELECT COUNT(*) AS num_totale_prestiti, COUNT(data_restituzione) AS num_prestiti_chiusi, (COUNT(*)-COUNT(data_restituzione)) AS num_prestiti_attivi
FROM prestito;

SELECT COUNT(*) AS num_prestiti_attivi
FROM prestito
WHERE data_restituzione IS NULL;

SELECT MIN(datan)
FROM utente;

SELECT MAX(datan)
FROM utente;

CREATE VIEW utenti_pre_90 AS
SELECT*
FROM utente
WHERE YEAR(datan) < 1990;

SELECT*
FROM utenti_pre_90
WHERE cognome LIKE 'r%'
ORDER BY cognome, nome;

SELECT*, timestampdiff(YEAR, datan, NOW()) AS eta
FROM utente;

CREATE VIEW utente_eta AS
SELECT*, TIMESTAMPDIFF(YEAR, datan, NOW()) AS eta
FROM utente;

SELECT*
FROM utente_eta
WHERE eta < 18
ORDER BY eta;

SELECT MIN(eta), MAX(eta), AVG(eta)
FROM utente_eta;

SELECT *
FROM prestito p
JOIN utente u ON u.num_tessera = p.num_tessera
JOIN copia c ON c.idc = p.idc
JOIN libro l ON l.idl = c.idl
WHERE cognome = 'Smith' AND nome = 'James';

SELECT nome, congnome, titolo
FROM prestito P, utente u, copia c, libro l
WHERE c.idc = p.idc
AND l.idc = c.idc
AND cognome = 'smith'
AND



/*
	Query semplici.
    Svolgere i seguenti esercizi senza fare uso di funzioni particolari.
*/

-- Selezionare nome e cognome degli utenti presenti nel database


-- Selezionare nome e cognome ordinando i risultati in modo crescente per cognome e nome

-- Selezionare nome, cognome e data di nascita. Ordinare i risultati in modo 
-- descrescente per data di nascita, poi in ordine alfabetico

-- Selezionare tutti i dati degli utenti nati nel 1988.

-- Selezionare tutti i dati degli utenti nati nel mese di luglio del 1989.

-- Selezionare i nomi distinti degli utenti presenti nel database. Ordinarli in ordine alfabetico.

-- Selezionare i primi 20 utenti in ordine alfabetico

-- Selezionare 20 utenti in ordine alfabetico dopo i primi 20

/**
  Esercizi con funzioni.
  Svolgere i seguenti esercizi utilizzando le funzioni viste nelle slide.
*/

-- Selezionare gli utenti nati nel 1990


-- Selezionare gli utenti nati nel mese di febbraio del 1980

-- Selezionare tutti i dati degli utenti che hanno il nome che inizia per "j"


-- Selezionare tutti i dati degli utenti che hanno il nome che inizia e finisce per "a"

-- Selezionare gli utenti che hanno il cognome che inizia per "m" e il nome che finisce per "k"

-- Elencare i cognomi distinti che hanno lunghezza esattamente 5 caratteri, 
-- utilizzare il costrutto LIKE

-- Quanti utenti ci sono all'interno della tabella utente?

-- Quanti nomi e cognomi distinti ci sono?


-- Quanti diversi anni di nascita ci sono?


-- Qual è la data di nascita dell'utente più anziano?


-- E di quello più giovane?


-- Creare una vista che mostra gli utenti nati prima del 1990

-- Selezionare i dati dalla vista


-- Creare una vista utente_eta aggiungendo un campo calcolato età.
-- Chiamare il nuovo campo eta.
-- Il campo deve calcolare l'età dell'utente in anni.
-- Suggerimento: utilizzare le funzioni CURDATE (o NOW) e TIMESTAMPDIFF


-- Utilizzando la vista, selezionare gli utenti con meno di 18 anni.
-- Ordinare il risultato per età.


-- Qual è l'età minima, media e massima degli utenti presenti?