use biblioteca;

/* Scrivere una stored procedure "ins_prestito" che ha come:
	- input: il numero di tessera di un utente e l'id della copia di un libro;
    - output: idp del prestito inserito se l'operazione va a buon fine (vedi dopo);
   La stored procedure:
	- Verifica che quella copia non sia già in prestito (non deve esistere
	un prestito relativo a quella copia con data_restituzione = NULL);
    - Se è già in prestito, restituisce un idp = -1
    - Se non è in prestito, inserisce il prestito con data_prestito uguale alla data attuale 
      (usare la funzione curdate). Poi restituisce l'idp generato (usare la funzione last_insert_id 
      per recuperarlo)
)*/

delimiter //
create procedure ins_prestito(
in numt int,
in copia int,
out id_prestito int)
begin
if exists(select * from prestito where data_restituzione is null and idc = copia)
then set id_prestito = -1;
else
insert into prestito(data_prestito, num_tessera, idc) values(curdate(), numt, copia);
select last_insert_id() into id_prestito;
end if;
end//
delimiter ;

call ins_prestito(2, 30, @idp);

select @idp;

select* from prestito where idp = @idp;

/* Supponiamo che la biblioteca acquisti le copie dei libri in stock.
   Ad esempio del libro X acquista 10 copie tutte della stessa edizione.
   Scrivere una stored procedure che inserisce le copie di un libro prendendo
   in input: l'id del libro (supponiamo sia già stato inserito), 
   l'edizione e il numero di copie da inserire.
 */
 
 delimiter //
 create procedure ins_copie(in id_libro int, in num_copie int, in edz int)
 begin
 declare i int default 0;
 while i < num_copie do
 insert into copia(idl, edizione) values (id_libro, edz);
 set i = i + 1;
 end while;
 end//
 delimiter ;
 
 call ins_copie(100, 20, 3);
 
 select*
 from copia
 where idl = 100 and edizione = 3;
 
 /*
	Scrivere un trigger che impedisce di inserire un prestito se la copia di un libro
    è già in prestito.
*/

delimiter //
create trigger check_prestito_insert
before insert
on prestito
for each row
begin
if exists (select* from prestito where idc = new.idc and data_restituzione is null)
then signal sqlstate '45000' set message_text = 'La copia è già in prestito';
end if;
end//
delimiter ;

select* from prestito where data_restituzione is null;

insert into prestito(data_prestito, num_tessera, idc) values (curdate(), 80, 177);

select * from prestito where data_restituzione is null;

	
/*
	Scrivere un trigger che impedisce di inserire un prestito se la copia di un libro
    è già in prestito.
*/
delimiter //
create trigger check_num_prestiti
after insert on prestito
for each row
begin
if exists(select num_tessera from prestito where data_restituzione is null
and num_tessera = new.num_tessera
group by num_tessera
having count(*) > 3) then
signal sqlstate '45000' set message_text = 'Numero massimo di prestiti superato';
end if;
end//
delimiter ;

insert into prestito(data_prestito, num_tessera, idc) values (curdate(), 1, 180);

insert into prestito(data_prestito, num_tessera, idc) values (curdate(), 2, 190), (curdate(), 1, 184);


