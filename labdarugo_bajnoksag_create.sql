CREATE DATABASE LabdarugoBajnoksagBeadando;
GO

USE LabdarugoBajnoksagBeadando;
GO

CREATE TABLE Csapatok (
    csapat_id INT PRIMARY KEY IDENTITY,
    nev NVARCHAR(100) NOT NULL UNIQUE
);


CREATE TABLE Fordulok (
    fordulo_id INT PRIMARY KEY IDENTITY,
    fordulo_szam INT NOT NULL,
    datum_kezdete DATE,
    datum_vege DATE
);

CREATE TABLE Merkozesek (
    merkozes_id INT PRIMARY KEY IDENTITY,
    datum DATE NOT NULL,
    hazai_csapat_id INT NOT NULL,
    vendeg_csapat_id INT NOT NULL,
    fordulo_id INT NOT NULL,
    FOREIGN KEY (hazai_csapat_id) REFERENCES Csapatok(csapat_id),
    FOREIGN KEY (vendeg_csapat_id) REFERENCES Csapatok(csapat_id),
    FOREIGN KEY (fordulo_id) REFERENCES Fordulok(fordulo_id)
);

CREATE TABLE Eredmenyek (
    eredmeny_id INT PRIMARY KEY IDENTITY,
    merkozes_id INT NOT NULL UNIQUE,
    hazai_gol INT,
    vendeg_gol INT,
    felido_hazai INT,
    felido_vendeg INT,
    FOREIGN KEY (merkozes_id) REFERENCES Merkozesek(merkozes_id)
);

CREATE TABLE Statisztikak (
    stat_id INT PRIMARY KEY IDENTITY,
    merkozes_id INT NOT NULL UNIQUE,
    hazai_loves INT,
    vendeg_loves INT,
    hazai_loves_kapura INT,
    vendeg_loves_kapura INT,
    hazai_sarga INT,
    vendeg_sarga INT,
    hazai_piros INT,
    vendeg_piros INT,
    FOREIGN KEY (merkozes_id) REFERENCES Merkozesek(merkozes_id)
);
