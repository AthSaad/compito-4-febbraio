drop database if exists negozio;
create database negozio;
use negozio;
drop table if exists dati;
create table dati (
cod_ordine varchar(10),
data_ordine datetime,
cod_prodotto varchar(10),
descrizione_prodotto varchar (15),
prezzo_vendita_prodotto decimal(14,4),
quantità_prodotto int,
prezzo_unitario_prodotto decimal(14,4),
giacenza_prodotto int,
cod_cliente  varchar(10),
nominativo varchar (15)
);

Insert into dati values ("OR01","2021-01-01 9:00:00","P01","PC xx",1150.00,1,1200.00,9,"C01","Rossi");
Insert into dati values ("OR01","2021-01-01 9:00:00","P02","Stampante ",300.00,1,300.00,19,"C01","Rossi");
Insert into dati values ("OR02","2021-02-02 10:00:00","P01","PC xx",1100.00,2,1200.00,7,"C02","Verdi");
Insert into dati values ("OR02","2021-02-02 10:00:00","P03","Tablet YY",350.00,1,350.00,3,"C02","Verdi");
Insert into dati values ("OR03","2021-02-02 14:00:00","P03","Tablet YY",340.00,1,350.00,2,"C01","Rossi");
Insert into dati values ("OR03","2021-02-02 14:00:00","P06","PC xx",1150.00,1,1200.00,5,"C01","Rossi");

drop table if exists clienti;
create table clienti (
cod_cliente  varchar(10),
nominativo varchar (15),
constraint pk_cod_cliente primary key (cod_cliente)
);
insert into clienti 
select distinct cod_cliente, nominativo from dati;

drop table if exists listino;
create table listino (
cod_prodotto varchar(10),
descrizione_prodotto varchar (15),
prezzo_unitario_prodotto decimal(14,4),
giacenza_prodotto int,
constraint pk_cod_prodotto primary key (cod_prodotto)
);
insert into listino 
select cod_prodotto,descrizione_prodotto,prezzo_unitario_prodotto,giacenza_prodotto from dati group by cod_prodotto;

create table ordini_emessi(
cod_ordine varchar(10),
data_ordine datetime,
cod_cliente varchar(10),
prezzo_vendita_prodotto decimal(14,4),
quantità_prodotto int,
constraint pk_cod_cordine primary key (cod_ordine),
constraint fk_cod_cliente foreign key (cod_cliente) references clienti(cod_cliente)
);
insert into ordini_emessi
select cod_ordine,data_ordine,cod_cliente,prezzo_vendita_prodotto,quantità_prodotto from dati group by cod_ordine;

create table dettagli_ordini(
cod_ordine varchar(10),
cod_prodotto varchar(10),
prezzo_unitario_prodotto decimal(14,4),
quantità_prodotto int,
constraint pk_cod_ordine_cod_prodotto primary key (cod_ordine, cod_prodotto),
constraint fk_cod_ordine foreign key (cod_ordine) references ordini_emessi(cod_ordine),
constraint fk_cod_prodotto foreign key (cod_prodotto) references listino(cod_prodotto)

);
insert into dettagli_ordini select distinct cod_ordine,cod_prodotto,prezzo_unitario_prodotto,giacenza_prodotto from dati;

-- creare un trigger che permetta di aggiornare la giacenza di ciascun prodotto all’atto della vendita.
delimiter $$
create trigger aggiorna_prodotti after insert on ordini_emessi
    for each row
    begin
		update listino set listino.giacenza_prodotto=(listino.giacenza_prodotto-new.listino.giacenza_prodotto)
		where listino.cod_prodotto=new.listino.cod_prodotto;
    end $$
delimiter ;

-- scrivere un’istruzione sql che consenta di calcolare l’importo totale per ogni ordine: cod_ordine,data,importo;
select cod_ordine,`data_ordine`,sum(prezzo_vendita_prodotto) from ordini_emessi group by cod_ordine;
-- scrivere un’istruzione sql che consenta di calcolare l’importo totale per ogni cliente: nominativo, importo;
select cod_cliente, sum(prezzo_vendita_prodotto* quantità_prodotto) from ordini_emessi group by cod_cliente;
-- scrivere un’istruzione sql che consenta di calcolare l’importo totale per ogni prodotto: cod_prodotto,descrizione,importo;
select cod_prodotto,descrizione_prodotto,prezzo_unitario_prodotto, sum(prezzo_unitario_prodotto*giacenza_prodotto)as importo_totale_prodotti from listino group by cod_prodotto;
-- scrivere un’istruzione sql che consenta di trovare il prodotto pìù venduto: cod_prodotto,descrizione;
-- scrivere un’istruzione sql che consenta di trovare il cliente con il fatturato maggiore: nominativo,importo;
-- scrivere un’istruzione sql che consenta di trovare il giorno con la frequenza di vendite maggiore: data, frequenza;
select data_ordine, count(quantità_prodotto)as prodotti_venduti from ordini_emessi order by prodotti_venduti;
