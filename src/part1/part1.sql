DROP TABLE IF EXISTS peers CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS checks CASCADE;
DROP TABLE IF EXISTS P2P CASCADE;
DROP TABLE IF EXISTS Verter CASCADE;
DROP TABLE IF EXISTS TransferredPoints CASCADE;
DROP TABLE IF EXISTS Friends CASCADE;
DROP TABLE IF EXISTS Recommendations CASCADE;
DROP TABLE IF EXISTS XP CASCADE;
DROP TABLE IF EXISTS TimeTracking CASCADE;
DROP TYPE IF EXISTS check_status CASCADE;

CREATE TABLE Peers (
	Nickname varchar(25) PRIMARY KEY,
	Birthday date NOT NULL 
);

CREATE TABLE Tasks (
	Title varchar(45) PRIMARY KEY,
	ParentTask varchar(45) REFERENCES Tasks(Title),
	MaxXP integer NOT NULL 
);

CREATE TABLE checks (
	ID serial PRIMARY KEY,
	Peer varchar(25) NOT NULL REFERENCES Peers(Nickname),
	Task varchar(45) NOT NULL REFERENCES Tasks(Title),
	Date date
);

CREATE TYPE check_status AS ENUM 
('Start', 'Success', 'Failure');

CREATE TABLE P2P (
	ID serial PRIMARY KEY,
	"Check" integer NOT NULL REFERENCES Checks(ID),
	CheckingPeer varchar(25) NOT NULL REFERENCES Peers(Nickname),
	State check_status,
	Time timestamp 
);

CREATE TABLE Verter (
	ID serial PRIMARY KEY,
	"Check" integer NOT NULL REFERENCES Checks(ID),
	State check_status,
	Time timestamp
);

CREATE TABLE TransferredPoints (
	ID serial PRIMARY KEY,
	CheckingPeer varchar(25) NOT NULL REFERENCES Peers(Nickname),
	CheckedPeer varchar(25) NOT NULL REFERENCES Peers(Nickname),
	PointsAmount integer NOT NULL DEFAULT 1
);

CREATE TABLE Friends (
	ID serial PRIMARY KEY,
	Peer1 varchar(25) NOT NULL REFERENCES Peers(Nickname),
	Peer2 varchar(25) NOT NULL REFERENCES Peers(Nickname)
);

CREATE TABLE Recommendations (
	ID serial PRIMARY KEY,
	Peer varchar(25) REFERENCES Peers(Nickname),
	RecommendedPeer varchar(25) REFERENCES Peers(Nickname),
	UNIQUE (Peer, RecommendedPeer)
);

CREATE TABLE XP (
	ID serial PRIMARY KEY,
	"Check" integer REFERENCES Checks(ID),
	XPAmount integer
);

CREATE TABLE TimeTracking (
	ID serial PRIMARY KEY,
	Peer varchar(25) REFERENCES Peers(Nickname),
	Date date,
	Time time,
	State SMALLINT CHECK (State IN (1, 2)) 
);