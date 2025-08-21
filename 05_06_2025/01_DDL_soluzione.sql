-- Creazione del database
CREATE DATABASE prenotazioni;

-- Attiva questo database
USE prenotazioni;

-- Creazione delle tabelle
CREATE DATABASE prenotazioni;

-- Si sposta sul db prenotazioni
USE prenotazioni;

/*
Edificio (idE, Nome, Indirizzo)
  PK: idE
  AK: Nome
*/
CREATE TABLE edificio(
	ide INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL UNIQUE,
    indirizzo VARCHAR(255) NOT NULL
);

/*
Aula (idA, NomeA, idE, Capienza)
 FK: idE REFERENCES Edificio
 AK: NomeA, idE
*/
CREATE TABLE aula(
	ida INT AUTO_INCREMENT PRIMARY KEY,
    nomea VARCHAR(255) NOT NULL,
    ide INT NOT NULL,
    capienza INT NOT NULL,
    FOREIGN KEY (ide) REFERENCES edificio(ide),
    UNIQUE (nomea, ide)
);
/*
Utente (idU, Email, Nominativo, Password)
 AK: email
*/
CREATE TABLE utente(
	idu INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    nominativo VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
);
/*Prenotazione (idP, OraInizio, OraFine, Data, idU, idA, Descr)
   FK: idU REFERECES Utente NOT NULL
FK: idA REFERENCES Edificio NOT NULL
Dominio OraInizio, OraFine compreso tra 8:00 e 19:00.
*/
CREATE TABLE prenotazione(
	idp INT PRIMARY KEY AUTO_INCREMENT,
    orainizio TIME NOT NULL,
    orafine TIME NOT NULL,
    data DATE NOT NULL,
    idu INT NOT NULL,
    ida INT NOT NULL,
    descr TEXT,
    FOREIGN KEY (idu) REFERENCES utente(idu),
    FOREIGN KEY (ida) REFERENCES aula(ida),
    CHECK(orainizio >= '8:00' AND orainizio <= '19:00'),
    CHECK(orafine >= '8:00' AND orafine <= '19:00')
);

-- Inserimento dei dati
INSERT INTO edificio(idE, nome, indirizzo) VALUES
(1, 'MO25 (Ingegneria)', 'Via Pietro Vivarelli 10, Modena'),
(2, 'Foro Boario (Economia)', 'Via Jacopo Berengario, 51, Modena');

INSERT INTO aula(idA, nomeA, idE, capienza) VALUES
(1, 'Aula C1.3', 2, 96),
(2, 'Aula P0.4', 1, 228);

INSERT INTO utente(idU, email, nominativo, password) VALUES
(1, 'luca.gagliardelli@unimore.it', 'Luca Gagliardelli', '12345');

INSERT INTO prenotazione(oraInizio, oraFine, data, idU, idA, descr) VALUES
('9:00', '11:00', '2024-05-20', 1, 2, 'Basi di dati'),
('17:30', '19:00', '2023-09-29', 1, 1, 'Business Intelligence');


/*
L’ora di inizio di una prenotazione deve essere 
antecedente all'ora di fine.
*/
ALTER TABLE prenotazione 
ADD CONSTRAINT CHECK(orainizio < orafine);

/*
La capienza di un’aula deve essere un numero positivo.
*/
ALTER TABLE aula
ADD CONSTRAINT CHECK(capienza > 0);

-- Modificare la password dell’utente Luca Gagliardelli in 4567.
UPDATE utente SET password = '4567';

-- Aumentare di 10 posti la capienza di tutte le aule del dipartimento di Ingegneria.
UPDATE aula SET capienza = capienza + 10 WHERE idE = 1;

-- Eliminare la prenotazione numero 2
DELETE FROM prenotazione WHERE idP = 2;

-- Eliminare l'aula P0.4
DELETE FROM aula WHERE nomeA = 'Aula P0.4' AND idE = 1;

-- Non si può eliminare, dobbiamo definire il vincolo cascade sulla foreign key.

-- Visualizza tutte le foreign key
SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'FOREIGN KEY';
-- Eliminiamo il vincolo di FK
ALTER TABLE prenotazione DROP CONSTRAINT prenotazione_ibfk_1;
-- Lo ricreiamo
ALTER TABLE prenotazione ADD CONSTRAINT FOREIGN KEY (ida) REFERENCES aula(ida) ON DELETE CASCADE ON UPDATE CASCADE;

-- Ora si può procedere con l'eliminazione
DELETE FROM aula WHERE nomeA = 'Aula P0.4' AND idE = 1;