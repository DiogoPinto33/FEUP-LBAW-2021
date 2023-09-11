create schema if not exists lbaw2103;

SET search_path TO lbaw2103;

-----------------------------------------
-- Drop old schema
-----------------------------------------

DROP TABLE IF EXISTS member CASCADE;
DROP TABLE IF EXISTS news CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS follow_member CASCADE;
DROP TABLE IF EXISTS topic CASCADE;
DROP TABLE IF EXISTS news_topic CASCADE;
DROP TABLE IF EXISTS follow_topic CASCADE;
DROP TABLE IF EXISTS vote_on_news CASCADE;
DROP TABLE IF EXISTS vote_on_comment CASCADE;
DROP TABLE IF EXISTS notification CASCADE;


-----------------------------------------
-- Tables
-----------------------------------------

-- Note that plural 'comments' and 'dates' names were adopted because comment and date are reserved words in PostgreSQL.

CREATE TABLE "member"(
  id SERIAL PRIMARY KEY,
  name  VARCHAR CONSTRAINT member_username_uk UNIQUE,
  password  VARCHAR NOT NULL,
  email     VARCHAR NOT NULL CONSTRAINT member_email_uk UNIQUE,
  profile_description VARCHAR,
  image     VARCHAR UNIQUE,
  dates     TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  reputation INTEGER DEFAULT 0 NOT NULL,
  is_admin  BOOLEAN DEFAULT FALSE NOT NULL
);

CREATE TABLE "news"(
  id_news SERIAL PRIMARY KEY,	
  writer  INTEGER REFERENCES member (id) ON DELETE SET NULL ON UPDATE CASCADE,
  title   VARCHAR NOT NULL CONSTRAINT news_title_uk UNIQUE,
  content VARCHAR NOT NULL,
  image   VARCHAR UNIQUE,
  dates   TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  reputation INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE "comments"(
  id_comment  SERIAL PRIMARY KEY,
  writer      INTEGER REFERENCES member (id) ON DELETE SET NULL ON UPDATE CASCADE,
  news        INTEGER REFERENCES news (id_news) ON DELETE RESTRICT ON UPDATE CASCADE,
  content     VARCHAR NOT NULL,
  dates       TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  reputation  INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE "follow_member"(
  follower INTEGER REFERENCES member (id) ON DELETE CASCADE ON UPDATE CASCADE,
  followed INTEGER REFERENCES member (id) ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY (follower, followed)
);

CREATE TABLE "topic"(
  id_topic  SERIAL PRIMARY KEY,
  name      VARCHAR NOT NULL CONSTRAINT topic_name_uk UNIQUE
);

CREATE TABLE "news_topic"(
  id_news INTEGER REFERENCES news (id_news) ON DELETE CASCADE ON UPDATE CASCADE,
  id_topic   INTEGER REFERENCES topic (id_topic) ON DELETE RESTRICT ON UPDATE CASCADE,
  PRIMARY KEY (id_news, id_topic)
);

CREATE TABLE "follow_topic"(
  id_member  INTEGER REFERENCES member (id) ON DELETE CASCADE ON UPDATE CASCADE,
  id_topic   INTEGER REFERENCES topic (id_topic) ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY (id_member, id_topic)
);

CREATE TABLE "vote_on_news"(
  member  INTEGER REFERENCES member (id) ON DELETE SET NULL ON UPDATE CASCADE,
  news    INTEGER REFERENCES news (id_news) ON DELETE RESTRICT ON UPDATE CASCADE,
  vote 	  INTEGER NOT NULL, 
  dates   TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (member, news),
  CONSTRAINT vote_ck CHECK ((vote = 1) OR (vote = -1))
);

CREATE TABLE "vote_on_comment"(
  member    INTEGER REFERENCES member (id) ON DELETE SET NULL ON UPDATE CASCADE,
  comments  INTEGER REFERENCES comments (id_comment) ON DELETE RESTRICT ON UPDATE CASCADE,
  vote 	    INTEGER NOT NULL,
  dates     TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (member, comments),
  CONSTRAINT vote_ck CHECK ((vote = 1) OR (vote = -1))
);

CREATE TABLE "notification"(
  id_notification			SERIAL PRIMARY KEY,
  comments					INTEGER DEFAULT NULL REFERENCES comments (id_comment) ON DELETE CASCADE ON UPDATE CASCADE,
  vote_on_news				INTEGER DEFAULT NULL,
  vote_on_news_author 		INTEGER DEFAULT NULL,
  vote_on_comment			INTEGER DEFAULT NULL,
  vote_on_comment_author	INTEGER DEFAULT NULL,
  notified_user 			INTEGER NOT NULL REFERENCES member (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (vote_on_news, vote_on_news_author) REFERENCES vote_on_news (news, member) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (vote_on_comment, vote_on_comment_author) REFERENCES vote_on_comment (comments, member) ON DELETE CASCADE ON UPDATE CASCADE
);

-----------------------------------------
-- Index
-----------------------------------------

DROP INDEX IF EXISTS write_news;
DROP INDEX IF EXISTS news_date;
DROP INDEX IF EXISTS news_reputation;
DROP INDEX IF EXISTS comment_writer;
DROP INDEX IF EXISTS comment_news;
DROP INDEX IF EXISTS order_by_follower;
DROP INDEX IF EXISTS order_by_followed;
DROP INDEX IF EXISTS news_topics;
DROP INDEX IF EXISTS member_topic;
DROP INDEX IF EXISTS news_vote;
DROP INDEX IF EXISTS comment_vote;
DROP INDEX IF EXISTS search_idx;
DROP INDEX IF EXISTS notified_user;

CREATE INDEX write_news ON news USING hash (writer);
CREATE INDEX news_date ON news USING BTREE (dates);
CREATE INDEX news_reputation ON news USING BTREE (reputation);
CREATE INDEX comment_writer ON comments USING hash (writer);
CREATE INDEX comment_news ON comments USING hash (news);
CREATE INDEX order_by_follower ON follow_member USING hash (follower);
CREATE INDEX order_by_followed ON follow_member USING hash (followed);
CREATE INDEX news_topics ON news_topic USING hash (id_topic);
CREATE INDEX member_topic ON follow_topic USING hash (id_member);
CREATE INDEX news_vote ON vote_on_news USING hash (news);
CREATE INDEX comment_vote ON vote_on_comment USING hash (comments);
CREATE INDEX notified_user ON notification USING hash (notified_user);


-----------------------------------------
-- User-defined Functions and Triggers
-----------------------------------------

---------------------- TRIGGER_01
DROP TRIGGER IF EXISTS news_search_update ON news;

ALTER TABLE news 
ADD COLUMN tsvectors TSVECTOR;                                                                                                               
CREATE OR REPLACE FUNCTION news_search_update() RETURNS TRIGGER AS $$                
BEGIN                                                                     
	IF TG_OP = 'INSERT' THEN                                                 
       NEW.tsvectors = (                                                  
         setweight(to_tsvector('english', NEW.title), 'A') ||             
         setweight(to_tsvector('english', NEW.content), 'B')              
        );                                                                
	END IF;                                                                  
	IF TG_OP = 'UPDATE' THEN                                                 
        IF (NEW.title <> OLD.title OR NEW.content <> OLD.content) THEN   
          NEW.tsvectors = (
            setweight(to_tsvector('english', NEW.title), 'A') ||
            setweight(to_tsvector('english', NEW.content), 'B')
           );
        END IF;
	END IF;
	RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER news_search_update
	BEFORE INSERT OR UPDATE ON news
	FOR EACH ROW
	EXECUTE PROCEDURE news_search_update();
 
-------------------- Related Index

CREATE INDEX search_idx ON news USING GIN (tsvectors);


---------------------- TRIGGER_02
DROP TRIGGER IF EXISTS vote_on_news_insert ON vote_on_news;

CREATE OR REPLACE FUNCTION vote_on_news_insert() RETURNS TRIGGER AS $$
DECLARE
    aux_writer INTEGER;
    aux_id_member INTEGER;        
BEGIN
    SELECT writer FROM news WHERE NEW.news = id_news INTO aux_writer;                                                                    
    SELECT id FROM member WHERE NEW.member = id INTO aux_id_member;
    IF (aux_writer = aux_id_member) THEN
        RAISE EXCEPTION 'Writer cannot vote on own news';
    END IF;
    UPDATE news SET reputation = reputation + NEW.vote  WHERE news.id_news = NEW.news;
     RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER vote_on_news_insert
	BEFORE INSERT ON vote_on_news
	FOR EACH ROW
	EXECUTE PROCEDURE vote_on_news_insert();

-------------------- TRIGGER_03
DROP TRIGGER IF EXISTS vote_on_news_update ON vote_on_news;

CREATE OR REPLACE FUNCTION vote_on_news_update() RETURNS TRIGGER AS $$    
BEGIN                                     
    IF (NEW.vote <> OLD.vote) THEN                                   
        UPDATE news SET reputation = reputation - OLD.vote + NEW.vote WHERE news.id_news = NEW.news;            
    END IF;
    RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER vote_on_news_update
	AFTER UPDATE ON vote_on_news
	FOR EACH ROW
	EXECUTE PROCEDURE vote_on_news_update();

-------------------- TRIGGER_04
DROP TRIGGER IF EXISTS vote_on_news_delete ON vote_on_news;

CREATE OR REPLACE FUNCTION vote_on_news_delete() RETURNS TRIGGER AS $$    
BEGIN
     UPDATE news SET reputation = reputation - OLD.vote WHERE news.id_news = OLD.news;
     RETURN OLD;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER vote_on_news_delete
	AFTER DELETE ON vote_on_news
	FOR EACH ROW
	EXECUTE PROCEDURE vote_on_news_delete();

-------------------- TRIGGER_05
DROP TRIGGER IF EXISTS vote_on_comment_insert ON vote_on_comment;

CREATE OR REPLACE FUNCTION vote_on_comment_insert() RETURNS TRIGGER AS $$
DECLARE
    aux_writer INTEGER;
    aux_id_member INTEGER;        
BEGIN
    SELECT writer FROM comments WHERE NEW.comments = id_comment INTO aux_writer;                                                                    
    SELECT id FROM member WHERE NEW.member = id INTO aux_id_member;
    IF (aux_writer = aux_id_member) THEN
        RAISE EXCEPTION 'Writer cannot vote on own comment';
    END IF;
    UPDATE comments SET reputation = reputation + NEW.vote WHERE comments.id_comment = NEW.comments;   
     RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER vote_on_comment_insert
	BEFORE INSERT ON vote_on_comment
	FOR EACH ROW
	EXECUTE PROCEDURE vote_on_comment_insert();

-------------------- TRIGGER_06
DROP TRIGGER IF EXISTS vote_on_comment_update ON vote_on_comment;

CREATE OR REPLACE FUNCTION vote_on_comment_update() RETURNS TRIGGER AS $$    
BEGIN                                     
    IF (NEW.vote <> OLD.vote) THEN                                   
		UPDATE comments SET reputation = reputation - OLD.vote + NEW.vote WHERE comments.id_comment = NEW.comments;            
    END IF;
    RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER vote_comment_update
	AFTER UPDATE ON vote_on_comment
	FOR EACH ROW
	EXECUTE PROCEDURE vote_on_comment_update();

-------------------- TRIGGER_07
DROP TRIGGER IF EXISTS vote_on_comment_delete ON vote_on_comment;

CREATE OR REPLACE FUNCTION vote_on_comment_delete() RETURNS TRIGGER AS $$       
BEGIN
    UPDATE comments SET reputation = reputation - OLD.vote  WHERE comments.id_comment = OLD.comments;
    RETURN OLD;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER vote_on_comment_delete
	AFTER DELETE ON vote_on_comment
	FOR EACH ROW
	EXECUTE PROCEDURE vote_on_comment_delete();

-------------------- TRIGGER_08
DROP TRIGGER IF EXISTS user_news_reputation ON news;

CREATE OR REPLACE FUNCTION user_news_reputation() RETURNS TRIGGER AS $$      
BEGIN
    UPDATE member SET reputation = reputation - OLD.reputation + NEW.reputation WHERE NEW.writer = member.id;
    RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER user_news_reputation
	AFTER UPDATE ON news
	FOR EACH ROW
	EXECUTE PROCEDURE user_news_reputation();

-------------------- TRIGGER_09
DROP TRIGGER IF EXISTS user_comment_reputation ON comments;

CREATE OR REPLACE FUNCTION user_comment_reputation() RETURNS TRIGGER AS $$      
BEGIN
    UPDATE member SET reputation = reputation - OLD.reputation + NEW.reputation WHERE NEW.writer = member.id;
    RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER user_comment_reputation
	AFTER UPDATE ON comments
	FOR EACH ROW
	EXECUTE PROCEDURE user_comment_reputation();

-------------------- TRIGGER_10
DROP TRIGGER IF EXISTS comment_date ON comments;

CREATE OR REPLACE FUNCTION check_comment_date() RETURNS TRIGGER AS $$     
BEGIN
	IF NEW.dates < (SELECT news.dates FROM news	WHERE news.id_news = NEW.news) 
	THEN
		RAISE EXCEPTION 'One can´t make a comment on a news before being released';
	END IF;
    RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER comment_date
	BEFORE INSERT ON comments
	FOR EACH ROW
	EXECUTE PROCEDURE check_comment_date();
 
------------------ TRIGGER_11
DROP TRIGGER IF EXISTS vote_news_date ON vote_on_news;

CREATE OR REPLACE FUNCTION check_vote_news_date() RETURNS TRIGGER AS $$     
BEGIN
	IF NEW.dates < (SELECT news.dates FROM news WHERE news.id_news = NEW.news) 
	THEN
		RAISE EXCEPTION 'One can´t vote on a news before being released';
	END IF;
    RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER vote_news_date
	BEFORE INSERT ON vote_on_news
	FOR EACH ROW
	EXECUTE PROCEDURE check_vote_news_date();

---------------------- TRIGGER_12
DROP TRIGGER IF EXISTS vote_comment_date ON vote_on_comment;

CREATE OR REPLACE FUNCTION check_vote_comment_date() RETURNS TRIGGER AS $$     
BEGIN
	IF NEW.dates < (SELECT comments.dates FROM comments WHERE comments.id_comment = NEW.comments) 
	THEN
		RAISE EXCEPTION 'One can´t vote on a comment before being released';
	END IF;
    RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER vote_comment_date
	BEFORE INSERT ON vote_on_comment
	FOR EACH ROW
	EXECUTE PROCEDURE check_vote_comment_date();

---------------------- TRIGGER_13
DROP TRIGGER IF EXISTS follow_member_insert ON follow_member;

CREATE OR REPLACE FUNCTION follow_member_insert() RETURNS TRIGGER AS $$    
BEGIN
     IF (NEW.follower = NEW.followed)
	 THEN
         RAISE EXCEPTION 'Member cannot follow himself';
     END IF;
	 RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER follow_member_insert
	BEFORE INSERT ON follow_member
	FOR EACH ROW
	EXECUTE PROCEDURE follow_member_insert();
	
	
-----------------------------------------
-- Database population
-----------------------------------------

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
	member(name, password, email, profile_description, image, dates, reputation, is_admin) 
VALUES
 ('News Editor', '$2y$10$73cjELm5ybrzGDGcIWuWjuhT6DgjHjks1c7thTH99hCDKzFlw29Tu', 'newseditor@fe.up.pt', 'I am a 53-year-old semi-professional sports person who enjoys swimming, horse riding and watching television.', 'https://robohash.org/blanditiisaaperiam.png?size=50x50&set=set1', '01/01/2021 ', 0, false),
 ('lface1', 'tntOnY', 'edelia1@usatoday.com', 'I am a 24-year-old sous chef who enjoys extreme ironing, watching television and podcasting.', 'https://robohash.org/repellendusexcepturilaboriosam.png?size=50x50&set=set1', '01/01/2021', 0, true),
 ('odemattia2', 'UODTRl3E', 'dpreedy2@wordpress.com', 'I am a 23-year-old health centre receptionist who enjoys recycling, listening to music and running.', 'https://robohash.org/molestiaeeumnesciunt.png?size=50x50&set=set1', '06/04/2021', 0, false),
 ('tharmstone3', 'JIZH0NdwZNkY', 'dbroggelli3@apache.org', 'I am a 29-year-old chef at chain restaurant who enjoys extreme ironing, bowling and binge-watching boxed sets.', 'https://robohash.org/blanditiisaliquidest.png?size=50x50&set=set1', '01/01/2021', 0, false),
 ('cpillington4', 'hlNxfR', 'rscrimshaw4@globo.com', 'I am a 73-year-old former government politician who enjoys reading, going to the movies and attending museums.', 'https://robohash.org/dolorequamblanditiis.png?size=50x50&set=set1', '01/01/2021', 0, false),
 ('avasser5', 'jAwSbTp', 'glaurenz5@1und1.de', 'I am a 29-year-old tradesperson assistant who enjoys helping old ladies across the road, social media and photography.', 'https://robohash.org/omnismolestiaeneque.png?size=50x50&set=set1', '02/03/2021', 0, true),
 ('mstokey6', 'gwnHiyoAwU', 'mgroger6@dmoz.org', 'I am a 35-year-old personal trainer who enjoys cookery, horse riding and walking.', 'https://robohash.org/idoditveniam.png?size=50x50&set=set1', '06/07/2021', 0, false),
 ('fmilbourne7', 'MVys1p90', 'breide7@cnbc.com', 'I am a 40-year-old intelligence researcher who enjoys meditation, badminton and football.', 'https://robohash.org/facilisutest.png?size=50x50&set=set1', '01/01/2021', 0, false),
 ('bgrut8', 'JZBxw3', 'mabadam8@merriam-webster.com', 'I am a 26-year-old former town counsellor who enjoys watching YouTube videos, golf and praying.', 'https://robohash.org/noniustomagnam.png?size=50x50&set=set1', '01/08/2021', 0, false),
 ('bholbury9', 'dhyqgCJj', 'vguerner9@businesswire.com', 'I am a 70-year-old former clerk who enjoys reading, theatre and cookery.', 'https://robohash.org/earecusandaeet.png?size=50x50&set=set1', '01/01/2021', 0, false),
 ('Admin', '$2y$10$Ib6shnuDYyU/qmkbAGuiuutBbFQ9ZAa4qDPyekfN5h8hu3VoP0e06', 'admin@fe.up.pt', 'I am the admin.', 'https://robohash.org/idodinm.png?size=51x50&set=set1', '12/12/2021', 0, true),
 ('Collab User', '$2y$10$95soLkRqimDreOyGfJ0KHOs.DiQGZMt8IT7NzpiZH2PJmIXHupox.', 'collab@fe.up.pt', 'I am a normal user', 'https://robohash.org/idodinm.png?size=170x100&set=set1', '12/12/2021', 0, false);

INSERT INTO
	news(writer, title, content, image, dates, reputation)
VALUES
 (1, 'Religious discrimination bill introduced to parliament', 'Prime Minister Scott Morrison has introduced proposed laws to parliament designed to protect religious Australians and religious institutions from existing state-based anti-discrimination laws.', 'https://imageresizer.static9.net.au/oxaXxFIh52kMnkfA4NQwt4lJogg=/500x0/https%3A%2F%2Fprod.static9.net.au%2Ffs%2F7ef6bb38-19c3-4d70-8f06-9168a2d3444a', '01/01/2021', 0),
 (2, 'Teachers to strike over unsustainable workloads and uncompetitive salaries', 'NSW public school teachers and principals will strike next month over workloads and salaries.', 'https://i.dailymail.co.uk/1s/2021/12/07/00/51426161-10282147-image-a-43_1638838441573.jpg', '01/01/2021', 0),
 (1, 'myGov website back online after widespread outage', 'The widespread outage that downed government services website myGov for more than seven hours has been resolved.', 'https://cdn.pixabay.com/photo/2016/11/18/12/09/white-male-1834131_960_720.jpg', '01/01/2021', 0),
 (1, 'The fear of missing out and the psychology of Black Friday', 'From its somewhat chequered origins in the 1950s when Philadelphia police reportedly started using the term to describe the traffic chaos in the streets after Thanksgiving, Black Friday has transformed into one of the most highly-anticipated shopping events of the year.', 'https://image.cnbcfm.com/api/v1/image/106271354-1575047415346rtx7b0z2.jpg?v=1575047507&w=720&h=405', '01/01/2021', 0),
 (1, 'Fears mount over Russian invasion of Ukraine', 'The US may send military advisors and new weaponry to Ukraine as Russia builds up forces near the border and US officials prepare allies for the possibility of another Russian invasion', 'https://imageresizer.static9.net.au/kEb1bYSnD9k-7aWLKU4mxfQbn-4=/1200x628/smart/https%3A%2F%2Fprod.static9.net.au%2Ffs%2F8b2a99c5-f291-4ee9-9096-77e40305133d', '01/01/2021', 0),
 (1, 'Australian fashion label becomes nations first to be carbon neutral', 'Menswear brand MJ Bale has become the nations first fully carbon-neutral fashion brand following a two-year process that offsets the entire companys emissions in green projects.', 'https://i.guim.co.uk/img/media/b867e7c949902d0afa24c6edf4339859910de214/0_0_3719_3074/master/3719.jpg?width=445&quality=45&auto=format&fit=max&dpr=2&s=b408b8d9344c5773a93c20a7706fb623', '01/01/2021', 0),
 (1, 'Britains army chief warns risk of war with Russia is greater than in Cold War', 'The risk of an accidental war breaking out between Russia and the West is greater than at any time during the Cold War, Britains most senior military officer has said in an interview with Times Radio.', 'https://dynaimage.cdn.cnn.com/cnn/c_fill,g_auto,w_1200,h_675,ar_16:9/https%3A%2F%2Fcdn.cnn.com%2Fcnnnext%2Fdam%2Fassets%2F210409080517-restricted-01-russia-forces-ukraine-border-0319.jpg', '01/01/2021', 0),
 (1, 'Millions of COVID-19 home testing kits made by Aussie company recalled in US', 'More than two million at-home COVID-19 testing kits made by Australian biotech company Ellume have been recalled by US health authorities.', 'https://imageresizer.static9.net.au/NvzVvjPcSYPPTg8mPKnx4S2Hr4o=/500x0/https%3A%2F%2Fprod.static9.net.au%2Ffs%2F938c3b68-4c3a-4346-97b3-0b8b5d49b1d0', '01/01/2021', 0);
 
INSERT INTO
	comments(writer, news, content, dates, reputation)
VALUES
 (2, 1, 'NEVER EVER vote for Labor or Liberal parties EVER Again.', '02/01/2021', 0),
 (3, 1, 'What about medical discrimination!!!!!', '02/01/2021', 0),
 (4, 1, 'How about a freedom of speech bill.', '02/01/2021', 0),
 (5, 1, 'Just remember this bill was Morrisons entire ambition as prime minister and its a complete joke.', '02/01/2021', 0),
 (1, 1, 'Morrison is clearly not a Christian by his behaviour.', '02/01/2021', 0),
 (6, 1, 'We are anything but a democracy.', '02/01/2021', 0),
 (7, 1, 'Despite Scotty saying he is a Christian, his actions since early 2020 show that he is more of a devil worshipper.', '02/01/2021', 0),
 (8, 1, 'Are politicians needed?', '02/01/2021', 0),
 (9, 1, 'Never voting mainstream parties again , time for a change and new start in Australia.', '02/01/2021', 0),
 (10, 1, 'Nice speech. Took him his ENTIRE term to write it. Perspective.', '02/01/2021', 0);
 
INSERT INTO 
    follow_member(follower, followed)
VALUES
 (6, 9),
 (3, 9),
 (8, 3),
 (2, 10),
 (1, 6);
 
INSERT INTO
    topic(name)
VALUES
 ('War'),
 ('Government'),
 ('Politics'),
 ('Education'),
 ('Health'),
 ('The Environment'),
 ('Economy'),
 ('Business'),
 ('Fashion'),
 ('Sports');
 
INSERT INTO
    news_topic(id_news, id_topic)
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
    follow_topic(id_member, id_topic)
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