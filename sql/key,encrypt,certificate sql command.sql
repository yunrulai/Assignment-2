--use SecureShopDB
SELECT 
    name,
    key_length,
    algorithm_desc,
    create_date
FROM sys.symmetric_keys;
--open symmetric key CreditCardKey decryption by certificate CreditCardCer
--create certificate CreditCardCer with subject = 'Credit card certificate'
--create symmetric key CreditCardKey  WITH ALGORITHM = AES_128 encryption by certificate CreditCardCer
--alter table payments add credit_card_num varbinary(8000)
/*UPDATE payments
SET credit_card_num =
    EncryptByKey(Key_GUID('CreditCardKey'), credit_card_num),
    IsEncrypted = 1
WHERE IsEncrypted = 0;*/

/*SELECT 
    CONVERT(varchar(100), DecryptByKey(credit_card_num)) AS DecryptedValue
FROM payments;*/

--insert into orders (id,user_id,total_amount) values (1,21,365)
--insert into payments (order_id,payment_method,credit_card_num) values ('2','Credit card','2222222222')
--select * from orders
--select * from users
/*update payments set credit_card_num = EncryptByKey(Key_GUID('CreditCardKey'),
    CONVERT(VARCHAR(20),255555555 ))where id = 7*/
--select * from payments
--alter table payments drop column credit_card_num
--delete from payments where id = 2

--backup certificate CreditCardCer to file = 'C:\certificates\CreditCardCer.cer' with private key ( file = 'C:\keys\CreditCardPVK.pvk', encryption by password = 'Pa$$w0rd')
--SELECT CONVERT(VARCHAR(20),credit_card_num ) from payments;
--ALTER TABLE payments ADD IsEncrypted BIT DEFAULT 0;
--drop symmetric key CreditCardKey

select * from order_items