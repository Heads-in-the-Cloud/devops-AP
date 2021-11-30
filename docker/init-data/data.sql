USE `utopia`;

INSERT INTO user_role (id, name) VALUES (1, 'AGENT');
INSERT INTO user_role (id, name) VALUES (2, 'USER');
INSERT INTO user_role (id, name) VALUES (3, 'GUEST');
INSERT INTO user_role (id, name) VALUES (4, 'ADMIN');

insert into user(id, role_id, given_name, family_name, username, email, password, phone)
values(
    '1',
    '4',
    'Angel',
    'Soto Pellot',
    'admin',
    'admin@smoothstack.com',
    '$2a$10$3JJHwCS2.mAAh5H0.J4xVeLYx4KKchqCe.I1kZ7xarzeqA9rQrOqe',     -- password = ADMIN
    '000-000-0000'
  );