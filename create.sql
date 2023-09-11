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
  id_member SERIAL PRIMARY KEY,
  username  VARCHAR NOT NULL CONSTRAINT member_username_uk UNIQUE,
  passwords VARCHAR NOT NULL,
  email     VARCHAR NOT NULL CONSTRAINT member_email_uk UNIQUE,
  profile_description VARCHAR,
  image     VARCHAR UNIQUE,
  dates     TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  reputation INTEGER DEFAULT 0 NOT NULL,
  is_admin  BOOLEAN NOT NULL
);

CREATE TABLE "news"(
  id_news SERIAL PRIMARY KEY,	
  writer  INTEGER REFERENCES member (id_member) ON DELETE SET NULL ON UPDATE CASCADE,
  title   VARCHAR NOT NULL CONSTRAINT news_title_uk UNIQUE,
  content VARCHAR NOT NULL,
  image   VARCHAR UNIQUE,
  dates   TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
  reputation INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE "comments"(
  id_comment  SERIAL PRIMARY KEY,
  writer      INTEGER REFERENCES member (id_member) ON DELETE SET NULL ON UPDATE CASCADE,
  news        INTEGER REFERENCES news (id_news) ON DELETE RESTRICT ON UPDATE CASCADE,
  content     VARCHAR NOT NULL,
  dates       TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  reputation  INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE "follow_member"(
  follower INTEGER REFERENCES member (id_member) ON DELETE CASCADE ON UPDATE CASCADE,
  followed INTEGER REFERENCES member (id_member) ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY (follower, followed)
);

CREATE TABLE "topic"(
  id_topic  SERIAL PRIMARY KEY,
  name      VARCHAR NOT NULL CONSTRAINT topic_name_uk UNIQUE
);

CREATE TABLE "news_topic"(
  id_news INTEGER REFERENCES news (id_news) ON DELETE CASCADE ON UPDATE CASCADE,
  topic   INTEGER REFERENCES topic (id_topic) ON DELETE RESTRICT ON UPDATE CASCADE,
  PRIMARY KEY (id_news, topic)
);

CREATE TABLE "follow_topic"(
  member  INTEGER REFERENCES member (id_member) ON DELETE CASCADE ON UPDATE CASCADE,
  topic   INTEGER REFERENCES topic (id_topic) ON DELETE CASCADE ON UPDATE CASCADE,
  PRIMARY KEY (member, topic)
);

CREATE TABLE "vote_on_news"(
  member  INTEGER REFERENCES member (id_member) ON DELETE SET NULL ON UPDATE CASCADE,
  news    INTEGER REFERENCES news (id_news) ON DELETE RESTRICT ON UPDATE CASCADE,
  vote 	  INTEGER NOT NULL, 
  dates   TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
  PRIMARY KEY (member, news),
  CONSTRAINT vote_ck CHECK ((vote = 1) OR (vote = -1))
);

CREATE TABLE "vote_on_comment"(
  member    INTEGER REFERENCES member (id_member) ON DELETE SET NULL ON UPDATE CASCADE,
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
  notified_user 			INTEGER NOT NULL REFERENCES member (id_member) ON DELETE CASCADE ON UPDATE CASCADE,
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
CREATE INDEX news_topics ON news_topic USING hash (topic);
CREATE INDEX member_topic ON follow_topic USING hash (member);
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
    SELECT id_member FROM member WHERE NEW.member = id_member INTO aux_id_member;
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
    SELECT id_member FROM member WHERE NEW.member = id_member INTO aux_id_member;
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
    UPDATE comments SET reputation = reputation - OLD.vote  WHERE comments.id_comment = NEW.comments;
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
    UPDATE member SET reputation = reputation - OLD.reputation + NEW.reputation WHERE NEW.writer = member.id_member;
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
    UPDATE member SET reputation = reputation - OLD.reputation + NEW.reputation WHERE NEW.writer = member.id_member;
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
	

---------------------- TRIGGER_14
DROP TRIGGER IF EXISTS insert_comment_notification ON comments;

CREATE OR REPLACE FUNCTION insert_comment_notification() RETURNS TRIGGER AS $$
DECLARE 
	aux_notified_user INTEGER;
BEGIN
	SELECT news.writer FROM news WHERE news.id_news = NEW.news INTO aux_notified_user;
    INSERT INTO notification(comments, notified_user) VALUES(NEW.id_comment, aux_notified_user);
	RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER insert_comment_notification
	AFTER INSERT ON comments
	FOR EACH ROW
	EXECUTE PROCEDURE insert_comment_notification();
	
	
---------------------- TRIGGER_15
DROP TRIGGER IF EXISTS insert_vote_on_news_notification ON vote_on_news;

CREATE OR REPLACE FUNCTION insert_vote_on_news_notification() RETURNS TRIGGER AS $$
DECLARE 
	aux_notified_user INTEGER;
BEGIN
	SELECT news.writer FROM news WHERE news.id_news = NEW.news INTO aux_notified_user;
    INSERT INTO notification(vote_on_news, vote_on_news_author, notified_user) VALUES(NEW.news, NEW.member, aux_notified_user);
	RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER insert_vote_on_news_notification
	AFTER INSERT ON vote_on_news
	FOR EACH ROW
	EXECUTE PROCEDURE insert_vote_on_news_notification();
	
	
---------------------- TRIGGER_16
DROP TRIGGER IF EXISTS insert_vote_on_comment_notification ON vote_on_comment;

CREATE OR REPLACE FUNCTION insert_vote_on_comment_notification() RETURNS TRIGGER AS $$
DECLARE 
	aux_notified_user INTEGER;
BEGIN
	SELECT comments.writer FROM comments WHERE comments.id_comment = NEW.comments INTO aux_notified_user;
    INSERT INTO notification(vote_on_comment, vote_on_comment_author, notified_user) VALUES(NEW.comments, NEW.member, aux_notified_user);
	RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER insert_vote_on_comment_notification
	AFTER INSERT ON vote_on_comment
	FOR EACH ROW
	EXECUTE PROCEDURE insert_vote_on_comment_notification();
	