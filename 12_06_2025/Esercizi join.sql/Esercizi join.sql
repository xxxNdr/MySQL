-- Utilizzare il database biblioteca
-- Ripasso esercizi SELECT
USE biblioteca;
SELECT COUNT(*)
FROM categoria;
SELECT *
FROM categoria
WHERE main_cat_id IS NULL;
SELECT *
FROM libro
WHERE YEAR(data_pub) >= 1998 AND YEAR(data_pub) <= 2000;

SELECT titolo
FROM libro
WHERE editore = 'berkley';

SELECT *
FROM libro
WHERE YEAR(data_pub) BETWEEN 1998 AND 2000;

SELECT *
FROM libro
WHERE titolo LIKE 'the%'
ORDER BY titolo;

SELECT COUNT(*)
FROM prestito
WHERE YEAR(data_prestito) = 2025;

CREATE VIEW durata_prestito AS
SELECT*, TIMESTAMPDIFF(DAY, data_prestito, data_restituzione ) AS durata
FROM prestito
WHERE data_restituzione IS NOT NULL;

SELECT AVG(durata)
FROM durata_prestito;

SELECT*
FROM prestito
WHERE data_restituzione IS NULL;

-- Visualizzare i dati dei libri che appartengono direttamente alla categoria 'Science'
SELECT l.*, cat_nome
FROM libro l
JOIN categoria c ON c.cat_id = l.cat_id
WHERE cat_nome = 'Science'
ORDER BY titolo;

-- Ordinare il risultato in ordine alfabetico per titolo del libro



-- Visualizzare i prestiti attivi (data fine è nulla se il prestito è attivo)
SELECT*
FROM prestito p
JOIN copia c ON c.idc = p.idc
JOIN libro l ON l.idl = c.idl
JOIN utente u ON u.num_tessera = p.num_tessera
WHERE data_restituzione IS NULL;
-- Mostrare i dati dell'utente che ha il libro, i dati della copia e del libro in prestito.

-- Visualizzare i dati delle sottocategorie che hanno come categoria principale 'Science'
SELECT c.cat_nome categoria, COALESCE(padre.cat_nome, '') categoria_padre
FROM categoria c
LEFT JOIN categoria padre ON c.main_cat_id = padre.cat_id
WHERE padre.cat_nome = 'science';

-- Visualizzare i dati dei libri scritti da Stephen King
SELECT l.idl, isbn, titolo, editore
FROM libro l
JOIN scrive s ON s.idl = l.idl
JOIN autore a ON a.ida = s.ida
WHERE a.nome = 'Stephen' AND a.cognome = 'King';

-- Visualizzare i nomi degli utenti che nel 2024 hanno preso in prestito libri scritti da Janice Lynn
SELECT u.nome, u.cognome
FROM utente u
JOIN prestito p ON p.num_tessera = u.num_tessera
JOIN copia c ON c.idc = p.idc
JOIN libro l ON l.idl = c.idl
JOIN scrive s ON s.idl = l.idl
JOIN autore a ON a.ida = s.ida
WHERE YEAR(data_prestito) = 2024
AND a.nome = 'janice' AND a.cognome = 'lynn'


