SET search_path TO lbaw2103;

DELETE FROM notification CASCADE;
DELETE FROM vote_on_news CASCADE;
DELETE FROM vote_on_comment CASCADE;
DELETE FROM news_topic CASCADE;
DELETE FROM comments CASCADE;
DELETE FROM follow_member CASCADE;
DELETE FROM follow_topic CASCADE;
DELETE FROM topic CASCADE;
DELETE FROM news CASCADE;
DELETE FROM member CASCADE;


INSERT INTO
	member(id_member, username, passwords, email, profile_description, image, dates, reputation, is_admin) 
VALUES
 (1, 'jcundict0', '3zOxwZ368o', 'rcashman0@alexa.com', 'I am a 53-year-old semi-professional sports person who enjoys swimming, horse riding and watching television.', 'https://robohash.org/blanditiisaaperiam.png?size=50x50&set=set1', '01/01/2021 ', 0, false),
 (2, 'lface1', 'tntOnY', 'edelia1@usatoday.com', 'I am a 24-year-old sous chef who enjoys extreme ironing, watching television and podcasting.', 'https://robohash.org/repellendusexcepturilaboriosam.png?size=50x50&set=set1', '01/01/2021', 0, true),
 (3, 'odemattia2', 'UODTRl3E', 'dpreedy2@wordpress.com', 'I am a 23-year-old health centre receptionist who enjoys recycling, listening to music and running.', 'https://robohash.org/molestiaeeumnesciunt.png?size=50x50&set=set1', '06/04/2021', 0, false),
 (4, 'tharmstone3', 'JIZH0NdwZNkY', 'dbroggelli3@apache.org', 'I am a 29-year-old chef at chain restaurant who enjoys extreme ironing, bowling and binge-watching boxed sets.', 'https://robohash.org/blanditiisaliquidest.png?size=50x50&set=set1', '01/01/2021', 0, false),
 (5, 'cpillington4', 'hlNxfR', 'rscrimshaw4@globo.com', 'I am a 73-year-old former government politician who enjoys reading, going to the movies and attending museums.', 'https://robohash.org/dolorequamblanditiis.png?size=50x50&set=set1', '01/01/2021', 0, false),
 (6, 'avasser5', 'jAwSbTp', 'glaurenz5@1und1.de', 'I am a 29-year-old tradesperson assistant who enjoys helping old ladies across the road, social media and photography.', 'https://robohash.org/omnismolestiaeneque.png?size=50x50&set=set1', '02/03/2021', 0, true),
 (7, 'mstokey6', 'gwnHiyoAwU', 'mgroger6@dmoz.org', 'I am a 35-year-old personal trainer who enjoys cookery, horse riding and walking.', 'https://robohash.org/idoditveniam.png?size=50x50&set=set1', '06/07/2021', 0, false),
 (8, 'fmilbourne7', 'MVys1p90', 'breide7@cnbc.com', 'I am a 40-year-old intelligence researcher who enjoys meditation, badminton and football.', 'https://robohash.org/facilisutest.png?size=50x50&set=set1', '01/01/2021', 0, false),
 (9, 'bgrut8', 'JZBxw3', 'mabadam8@merriam-webster.com', 'I am a 26-year-old former town counsellor who enjoys watching YouTube videos, golf and praying.', 'https://robohash.org/noniustomagnam.png?size=50x50&set=set1', '01/08/2021', 0, false),
 (10, 'bholbury9', 'dhyqgCJj', 'vguerner9@businesswire.com', 'I am a 70-year-old former clerk who enjoys reading, theatre and cookery.', 'https://robohash.org/earecusandaeet.png?size=50x50&set=set1', '01/01/2021', 0, false);

INSERT INTO
	news(id_news, writer, title, content, image, dates, reputation)
VALUES
 (1, 1, 'Religious discrimination bill introduced to parliament', 'Prime Minister Scott Morrison has introduced proposed laws to parliament designed to protect religious Australians and religious institutions from existing state-based anti-discrimination laws.', 'https://robohash.org/quaeratvoluptasaut.png?size=50x50&set=set1', '01/01/2021', 0),
 (2, 2, 'Thousands of NSW teachers to strike over unsustainable workloads and uncompetitive salaries', 'NSW public school teachers and principals will strike next month over workloads and salaries.', 'https://robohash.org/doloremeumnisi.png?size=50x50&set=set1', '01/01/2021', 0),
 (3, 1, 'myGov website back online after widespread outage', 'The widespread outage that downed government services website myGov for more than seven hours has been resolved.', 'https://robohash.org/quiaquovoluptatum.png?size=50x50&set=set1', '01/01/2021', 0),
 (4, 1, 'The fear of missing out and the psychology of Black Friday', 'From its somewhat chequered origins in the 1950s when Philadelphia police reportedly started using the term to describe the traffic chaos in the streets after Thanksgiving, Black Friday has transformed into one of the most highly-anticipated shopping events of the year.', 'https://robohash.org/dolorembeataeaccusamus.png?size=50x50&set=set1', '01/01/2021', 0),
 (5, 1, 'Fears mount over Russian invasion of Ukraine', 'The US may send military advisors and new weaponry to Ukraine as Russia builds up forces near the border and US officials prepare allies for the possibility of another Russian invasion', 'https://robohash.org/voluptatibusquiaquasi.png?size=50x50&set=set1', '01/01/2021', 0),
 (6, 1, 'Australian fashion label becomes nations first to be carbon neutral', 'Menswear brand MJ Bale has become the nations first fully carbon-neutral fashion brand following a two-year process that offsets the entire companys emissions in green projects.', 'https://robohash.org/temporibuspraesentiumaut.png?size=50x50&set=set1', '01/01/2021', 0),
 (7, 1, 'Britains army chief warns risk of accidental war with Russia is greater than during Cold War', 'The risk of an accidental war breaking out between Russia and the West is greater than at any time during the Cold War, Britains most senior military officer has said in an interview with Times Radio.', 'https://robohash.org/animirerumest.png?size=50x50&set=set1', '01/01/2021', 0),
 (8, 1, 'Millions of COVID-19 home testing kits made by Aussie company recalled in US', 'More than two million at-home COVID-19 testing kits made by Australian biotech company Ellume have been recalled by US health authorities.', 'https://robohash.org/possimuseaqueet.png?size=50x50&set=set1', '01/01/2021', 0);
 
INSERT INTO
	comments(id_comment, writer, news, content, dates, reputation)
VALUES
 (1, 2, 1, 'NEVER EVER vote for Labor or Liberal parties EVER Again.', '02/01/2021', 0),
 (2, 3, 1, 'What about medical discrimination!!!!!', '02/01/2021', 0),
 (3, 4, 1, 'How about a freedom of speech bill.', '02/01/2021', 0),
 (4, 5, 1, 'Just remember this bill was Morrisons entire ambition as prime minister and its a complete joke.', '02/01/2021', 0),
 (5, 1, 1, 'Morrison is clearly not a Christian by his behaviour.', '02/01/2021', 0),
 (6, 6, 1, 'We are anything but a democracy.', '02/01/2021', 0),
 (7, 7, 1, 'Despite Scotty saying he is a Christian, his actions since early 2020 show that he is more of a devil worshipper.', '02/01/2021', 0),
 (8, 8, 1, 'Are politicians needed?', '02/01/2021', 0),
 (9, 9, 1, 'Never voting mainstream parties again , time for a change and new start in Australia.', '02/01/2021', 0),
 (10, 10, 1, 'Nice speech. Took him his ENTIRE term to write it. Perspective.', '02/01/2021', 0);
 
INSERT INTO 
    follow_member(follower, followed)
VALUES
 (6, 9),
 (3, 9),
 (8, 3),
 (2, 10),
 (1, 6);
 
INSERT INTO
    topic(id_topic, name)
VALUES
 (1, 'War'),
 (2, 'Government'),
 (3, 'Politics'),
 (4, 'Education'),
 (5, 'Health'),
 (6, 'The Environment'),
 (7, 'Economy'),
 (8, 'Business'),
 (9, 'Fashion'),
 (10, 'Entertainment');
 
INSERT INTO
    news_topic(id_news, topic)
VALUES
 (1, 3),
 (7, 1),
 (3, 2),
 (4, 7),
 (5, 1),
 (2, 4),
 (6, 9),
 (8, 5);
 
INSERT INTO
    follow_topic(member, topic)
VALUES
 (3, 1),
 (6, 1),
 (2, 2),
 (9, 5),
 (10, 8),
 (10, 7),
 (1, 7),
 (3, 2),
 (7, 3),
 (4, 4);
 
INSERT INTO 
	vote_on_news(member, news, vote, dates)
VALUES
 (10, 1, 1, '01/01/2021'),
 (2, 1, 1, '01/01/2021'),
 (3, 1, 1, '01/01/2021'),
 (4, 1, -1, '01/01/2021'),
 (5, 1, 1, '01/01/2021');
 
INSERT INTO 
	vote_on_comment(member, comments, vote, dates)
VALUES
 (1, 1, 1, '02/01/2021'),
 (5, 1, 1, '02/01/2021'),
 (3, 1, 1, '02/01/2021'),
 (4, 1, -1, '02/01/2021');
