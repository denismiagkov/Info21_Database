INSERT INTO peers(nickname, birthday) VALUES ('john', '1984-01-22');
INSERT INTO peers(nickname, birthday) VALUES ('paul', '1985-04-07');
INSERT INTO peers(nickname, birthday) VALUES ('george', '1987-04-06');
INSERT INTO peers(nickname, birthday) VALUES ('ringo', '1983-02-23');
INSERT INTO peers(nickname, birthday) VALUES ('mick', '1991-03-15');
INSERT INTO peers(nickname, birthday) VALUES ('janis', '1998-05-01');

INSERT INTO tasks(title, parenttask, maxxp) VALUES ('intro', NULL, 350);
INSERT INTO tasks(title, parenttask, maxxp) VALUES ('SQL1', 'intro', 600);
INSERT INTO tasks(title, parenttask, maxxp) VALUES ('SQL2', 'SQL1', 750);
INSERT INTO tasks(title, parenttask, maxxp) VALUES ('SQL3', 'SQL2', 800);
INSERT INTO tasks(title, parenttask, maxxp) VALUES ('linux1', 'intro', 400);
INSERT INTO tasks(title, parenttask, maxxp) VALUES ('linux2', 'linux1', 550);
INSERT INTO tasks(title, parenttask, maxxp) VALUES ('linux3', 'linux2', 650);
INSERT INTO tasks(title, parenttask, maxxp) VALUES ('linux4', 'linux3', 700);
INSERT INTO tasks(title, parenttask, maxxp) VALUES ('linux5', 'linux4', 800);

INSERT INTO checks (peer, task, "date") VALUES ('john', 'intro', '2023-01-20');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (1, 'ringo', 'Start', '2023-01-20');
INSERT INTO checks (peer, task, "date") VALUES ('paul', 'intro', '2023-01-20');
INSERT INTO p2p("Check", checkingpeer, state, "time")
VALUES (2, 'mick', 'Start', '2023-01-20');
INSERT INTO checks (peer, task, "date") VALUES ('george', 'intro', '2023-01-21');
INSERT INTO p2p("Check", checkingpeer, state, "time")
VALUES (3, 'janis', 'Start', '2023-01-21');
INSERT INTO p2p("Check", checkingpeer, state, "time")
VALUES (1, 'ringo', 'Success', '2023-01-22');
INSERT INTO checks (peer, task, "date") VALUES ('john', 'SQL1', '2023-01-22');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (4, 'george', 'Start', '2023-01-22');
INSERT INTO p2p("Check", checkingpeer, state, "time")
VALUES (2, 'mick', 'Success', '2023-01-22');
INSERT INTO checks (peer, task, "date") VALUES ('paul', 'linux1', '2023-01-22');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (5, 'janis', 'Start', '2023-01-22');
INSERT INTO checks (peer, task, "date") VALUES ('ringo', 'intro', '2023-01-23');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (6, 'john', 'Start', '2023-01-23');
INSERT INTO checks (peer, task, "date") VALUES ('mick', 'intro', '2023-01-23');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (7, 'paul', 'Start', '2023-01-23');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (3, 'janis', 'Success', '2023-01-23 08:13:51');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (6, 'john', 'Success', '2023-01-24 17:24:41');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (7, 'paul', 'Success', '2023-01-25 10:43:53');
INSERT INTO checks (peer, task, "date") VALUES ('george', 'linux1', '2023-01-28');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (8, 'paul', 'Start', '2023-01-28 13:35:20');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (4, 'george', 'Success', '2023-01-31');
INSERT INTO checks (peer, task, "date") VALUES ('ringo', 'SQL1', '2023-02-01');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (9, 'janis', 'Start', '2023-02-01 18:39:42');
INSERT INTO checks (peer, task, "date") VALUES ('mick', 'SQL1', '2023-02-04');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (10, 'paul', 'Start', '2023-02-04 10:23:12');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (5, 'janis', 'Success', '2023-02-07 09:19:07');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (8, 'paul', 'Success', '2023-02-07 15:49:53');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (9, 'janis', 'Failure', '2023-02-09 19:18:07');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (10, 'paul', 'Success', '2023-02-09 07:37:18');
INSERT INTO checks (peer, task, "date") VALUES ('john', 'SQL2', '2023-02-11');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (11, 'paul', 'Start', '2023-02-11 14:31:22');
INSERT INTO checks (peer, task, "date") VALUES ('george', 'linux2', '2023-02-14');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (12, 'mick', 'Start', '2023-02-14 15:31:22');
INSERT INTO checks (peer, task, "date") VALUES ('paul', 'linux2', '2023-02-14');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (13, 'john', 'Start', '2023-02-14 16:12:52');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (11, 'paul', 'Success', '2023-02-17 20:23:53');
INSERT INTO checks (peer, task, "date") VALUES ('mick', 'SQL2', '2023-02-18');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (14, 'george', 'Start', '2023-02-18 21:12:58');
INSERT INTO checks (peer, task, "date") VALUES ('ringo', 'SQL1', '2023-02-19');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (15, 'janis', 'Start', '2023-02-19 09:44:42');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (12, 'mick', 'Failure', '2023-02-19 10:41:22');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (13, 'john', 'Success', '2023-02-21 15:52:08');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (14, 'george', 'Failure', '2023-02-21 13:12:58');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (15, 'janis', 'Failure', '2023-02-23 14:22:34');
INSERT INTO checks (peer, task, "date") VALUES ('john', 'SQL3', '2023-02-25');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (16, 'paul', 'Start', '2023-02-25 09:14:22');
INSERT INTO checks (peer, task, "date") VALUES ('paul', 'linux3', '2023-02-28');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (17, 'mick', 'Start', '2023-02-28 10:00:11');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (17, 'mick', 'Success', '2023-03-02 11:10:19');
INSERT INTO checks (peer, task, "date") VALUES ('paul', 'linux4', '2023-03-02');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (18, 'ringo', 'Start', '2023-03-02 17:30:17');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (16, 'paul', 'Success', '2023-03-03 16:42:53');
INSERT INTO checks (peer, task, "date") VALUES ('george', 'linux2', '2023-03-05');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (19, 'janis', 'Start', '2023-03-05 20:40:16');
INSERT INTO checks (peer, task, "date") VALUES ('ringo', 'SQL1', '2023-03-06');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (20, 'mick', 'Start', '2023-03-06 19:54:16');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (18, 'ringo', 'Success', '2023-03-08 12:10:47');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (19, 'janis', 'Success', '2023-03-10 21:27:48');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (20, 'mick', 'Success', '2023-03-11 14:37:17');
INSERT INTO checks (peer, task, "date") VALUES ('john', 'linux1', '2023-03-11');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (21, 'ringo', 'Start', '2023-03-11 17:30:17');
INSERT INTO checks (peer, task, "date") VALUES ('mick', 'SQL2', '2023-03-12');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (22, 'ringo', 'Start', '2023-03-12 17:30:17');
INSERT INTO checks (peer, task, "date") VALUES ('paul', 'linux5', '2023-03-12');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (23, 'john', 'Start', '2023-03-12 11:36:13');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (23, 'john', 'Success', '2023-03-15 12:16:14');
INSERT INTO checks (peer, task, "date") VALUES ('paul', 'SQL1', '2023-03-18');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (24, 'john', 'Start', '2023-03-18 13:46:13');
INSERT INTO checks (peer, task, "date") VALUES ('ringo', 'SQL1', '2023-03-20');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (25, 'janis', 'Start', '2023-03-20 10:24:46');
INSERT INTO p2p("Check", checkingpeer, state, "time") 
VALUES (25, 'janis', 'Success', '2023-03-20 15:35:19');

INSERT INTO verter ("Check", state, "time") VALUES (7, 'Start', '2023-01-25 11:00:15');
INSERT INTO verter ("Check", state, "time") VALUES (7, 'Success', '2023-01-25 12:30:00');
INSERT INTO verter ("Check", state, "time") VALUES (13, 'Start', '2023-02-21 16:00:00');
INSERT INTO verter ("Check", state, "time") VALUES (13, 'Success', '2023-02-21 17:30:00');
INSERT INTO verter ("Check", state, "time") VALUES (17, 'Start', '2023-03-02 11:30:00');
INSERT INTO verter ("Check", state, "time") VALUES (17, 'Success', '2023-03-02 13:00:00');
INSERT INTO verter ("Check", state, "time") VALUES (20, 'Start', '2023-03-11 15:00:00');
INSERT INTO verter ("Check", state, "time") VALUES (20, 'Failure', '2023-03-11 16:30:00');

INSERT INTO friends(peer1, peer2) VALUES ('john', 'george');
INSERT INTO friends(peer1, peer2) VALUES ('john', 'ringo');
INSERT INTO friends(peer1, peer2) VALUES ('george', 'ringo');
INSERT INTO friends(peer1, peer2) VALUES ('paul', 'ringo');
INSERT INTO friends(peer1, peer2) VALUES ('paul', 'george');
INSERT INTO friends(peer1, peer2) VALUES ('mick', 'john');

INSERT INTO recommendations (peer, recommendedpeer) values('paul', 'mick');
INSERT INTO recommendations (peer, recommendedpeer) values('john', 'janis');
INSERT INTO recommendations (peer, recommendedpeer) values('ringo', 'mick');
INSERT INTO recommendations (peer, recommendedpeer) values('george', 'janis');
INSERT INTO recommendations (peer, recommendedpeer) values('mick', 'janis');

INSERT INTO xp ("Check", xpamount) VALUES (1, 350);
INSERT INTO xp ("Check", xpamount) VALUES (2, 300);
INSERT INTO xp ("Check", xpamount) VALUES (3, 250);
INSERT INTO xp ("Check", xpamount) VALUES (6, 350);
INSERT INTO xp ("Check", xpamount) VALUES (7, 300);
INSERT INTO xp ("Check", xpamount) VALUES (4, 550);
INSERT INTO xp ("Check", xpamount) VALUES (5, 350);
INSERT INTO xp ("Check", xpamount) VALUES (8, 400);
INSERT INTO xp ("Check", xpamount) VALUES (10, 600);
INSERT INTO xp ("Check", xpamount) VALUES (11, 700);
INSERT INTO xp ("Check", xpamount) VALUES (13, 500);
INSERT INTO xp ("Check", xpamount) VALUES (17, 250);
INSERT INTO xp ("Check", xpamount) VALUES (16, 800);
INSERT INTO xp ("Check", xpamount) VALUES (18, 650);
INSERT INTO xp ("Check", xpamount) VALUES (19, 450);
INSERT INTO xp ("Check", xpamount) VALUES (23, 550);
INSERT INTO xp ("Check", xpamount) VALUES (25, 600);


INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('paul', '2023-01-15', '08:24:45', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('mick', '2023-01-15', '11:54:45', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('mick', '2023-01-15', '14:29:25', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('paul', '2023-01-15', '18:23:25', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('john', '2023-01-19', '09:29:45', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('janis', '2023-01-19', '12:14:45', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('janis', '2023-01-19', '14:49:25', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('janis', '2023-01-19', '16:24:45', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('john', '2023-01-19', '18:43:25', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('janis', '2023-01-19', '20:39:34', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('john', '2023-01-21', '12:49:25', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('john', '2023-01-21', '14:19:22', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('ringo', '2023-01-25', '10:28:47', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('george', '2023-01-25', '11:24:05', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('ringo', '2023-01-25', '15:19:28', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('george', '2023-01-25', '21:23:25', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('john', '2023-01-28', '10:43:29', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('john', '2023-01-28', '12:11:31', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('paul', '2023-02-03', '07:54:27', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('paul', '2023-02-03', '11:57:45', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('george', '2023-02-09', '12:34:27', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('george', '2023-02-09', '14:58:45', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('janis', '2023-02-15', '09:39:27', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('mick', '2023-02-15', '10:42:27', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('mick', '2023-02-15', '13:05:45', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('janis', '2023-02-15', '15:04:31', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('mick', '2023-02-15', '15:32:57', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('mick', '2023-02-15', '17:45:45', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('john', '2023-02-21', '09:47:17', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('john', '2023-02-21', '17:08:42', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('ringo', '2023-02-28', '14:52:13', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('ringo', '2023-02-28', '21:55:45', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('mick', '2023-03-10', '07:32:27', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('mick', '2023-03-10', '12:45:45', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('ringo', '2023-03-10', '13:38:07', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('mick', '2023-03-10', '17:18:07', 1);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('mick', '2023-03-10', '18:12:40', 2);
INSERT INTO timetracking (peer, "date", "time", state)
VALUES ('ringo', '2023-03-10', '22:49:10', 2);