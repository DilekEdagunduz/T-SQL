--Kaynaklar
-- https://www.sqlservertutorial.net/
-- https://www.w3schools.com/sql/default.asp


-- önce kayıt etmemiz lazım yani create ile başlayıp end e kadar al ve f5 bas daha sonra execu al f5 bas !!!!!!!!!!!!1

-- declare değişken tanımlama
declare @number int
set @number = 3declare @name nvarchar
set @name = 'Çağatay'

-- yazdırma işlemi
declare @counter int
set @counter = 0while(@counter < 10)
begin
print('Yunus Emre')
set @counter = @counter + 1
end

-- create kulanıldığında vt na kayıt eder 
create procedure sp_ProductCatList
as
begin
select
p.ProductName,
c.CategoryName,
p.UnitPrice
from Products as p
inner join Categories as c
on p.CategoryID = c.ID
end

-- metotu çalıştırıyor
exec sp_ProductCatList

-- alter: Değiştirme yapar eğer bu yöntem ile yapmak istemezsek vt dosyasının üzerine gelip sağ tık yapıp modifiye edebiliriz.
-- procedure : Metot oluşturma
alter procedure sp_ProductCatList
as
begin
select
p.ProductName,
c.CategoryName,
p.UnitPrice,
p.UnitsInStock
from Products as p
inner join Categories as c
on p.CategoryID = c.ID
end

-- önce kayıt etmemiz lazım yani create ile başlayıp end e kadar al ve f5 bas daha sonra execu al f5 bas !!!!!!!!!!!!1
create procedure sp_ProductListByPrice(@price money)
as
begin
select * from Products where UnitPrice > @price
end

exec sp_ProductListByPrice 20

-- dışarıdan name desc alıp o değerleri büyüt ve vt ekle
alter procedure sp_InsertCategory(@name nvarchar(max), @desc nvarchar(max))
as
begin
insert into Categories(CategoryName,Description) values(UPPER(@name), UPPER(@desc))
end



exec sp_InsertCategory 'Sport','Sport products'

-- IF EXISTIS ile select sorgusunun sonucu olup olmadığını kontrol eder
IF EXISTS(select * from Categories where CategoryID = 1)
begin
print('Böyle bir kategori mevcut!')
end

--@@IDENTITY eklenen son elamanın ıd sını  verir.
insert into Categories(CategoryName, Description) values('Sport', 'Sport products')
select @@IDENTITY

select @@IDENTITY
select IDENT_CURRENT('Products')

create procedure sp_addProductWithCompanyName(@productName nvarchar(MAX), @unitPrice money, @companyName nvarchar(MAX))
as
begin
--bu isimde bir companyName e sahip olan Supplier var mı?
declare @supplierID int

----------------------------------------------------------------------------------------

if EXISTS(select * from Suppliers where CompanyName = @companyName)
begin
set @supplierID = (select SupplierID from Suppliers where CompanyName = @companyName)
end
else
begin
insert into Suppliers(CompanyName) values(@companyName)
set @supplierID = @@IDENTITY
end

insert into Products(ProductName,UnitPrice,SupplierID) values(@productName, @unitPrice, @supplierID)

end

exec sp_addProductWithCompanyName 'Siemens-2',2000,'DEU Products'

----------------------------------------------------------------------------------------
-- dışarıdan fiyat alan ve o fiyattan büyük kaç adet ürün olduğunu return eden store procedure
-- önce, 
-- 1-) begin end çalıştır 
-- 2-) daha sonra declare exec 
-- 3-) ve en sonda select  çalıştırmalısın

create procedure sp_getProductsCountByPrice(@price money)
as
begin
return (select COUNT(*) from Products where UnitPrice > @price)
end

declare @productCount int
exec @productCount = sp_getProductsCountByPrice 20

--select @productCount

print (@productCount) --şeklinde yazarsak direkt tabosuz yazdırır fakat yukarıdaki tablo şeklnde yazdırır.

-- 1-)Dışarıdan CompanyName,ContanctName ve ContactTitle alan ve yeni bir supplier ekleyen store procedure
create procedure sp_getcmpname (@companyname nvarchar(max), @contactname nvarchar(max), @contacttitle nvarchar(max))
as 
begin 
insert into Suppliers(CompanyName,ContactName,ContactTitle) values(@companyname, @contactname, @contacttitle)
end
exec sp_getcmpname 'deneme1','deneme2','deneme3'

-- 2-) Dışarıdan stok adedi alan ve o stok adedinin altında ürünleri select olarak yazan store procedure
 create procedure pr_getproduct (@stock int )
 as 
 begin
 select * from Products where UnitsInStock<@stock
 end
exec  pr_getproduct 10


-- 3-) Dışarıdan bir ürün adı alan, ürün varsa 1 yoksa 0 print eden store procedure
create procedure pr_getproductname (@productname nvarchar(MAX))
as 
begin
if EXISTS(select * from Products where ProductName=@productname)
begin
print ('1')
end
else
begin 
print ('0')
end
end

-- 4-) 

-- 5-) Dışarıdan yıl ve ay alan  ve buna göre siparişleri (orderdate) tarihine göre tersten sıralayıp  bana veren store procedure
alter procedure sp_GetOrderByDateFilter ( @month int, @year int)
as
begin 
select * from Orders where YEAR(OrderDate)=@year and MONTH (OrderDate) =@month
order by OrderDate desc
end
exec sp_GetOrderByDateFilter 10, 1997

-- 6-) Dışarıdan yıl alan ve aldığı yıla göre OrderID, Customerin companyName i, Customer ın Contact title ve siparişin toplam  tutarı seklinde 4 kolonu 
--	bana veren store procedure
--Aşağıda mantık hatası varmış
alter procedure sp_GetOrderDetailByYear(@year int)
as 
begin
select SUM(od.Quantity*od.UnitPrice) from Orders as o 
inner join Customers as c
on o.CustomerID=c.CustomerID
inner join [Order Details] as od
on o.OrderID = od.OrderID
where YEAR (o.OrderDate)=@year
end 
--------------------------------------------------------------------------------------
create procedure sp_GetOrdersDetailByYear(@year int)
as
begin
select
o.OrderID,
c.CompanyName,
c.ContactTitle,
SUM(od.Quantity * od.UnitPrice)
from Orders as o
inner join Customers as c
on o.CustomerID = c.CustomerID
inner join [Order Details] as od
on o.OrderID = od.OrderID
where YEAR(o.OrderDate) = @year
group by o.OrderID, c.CompanyName, c.ContactTitle
end

--Geciken siparişleri bana veren store procedure
create procedure sp_GetDelay 
as 
begin 
select * from Orders where  RequiredDate <ShippedDate
end
--Kaç adet geciken sipariş olduğunu print eden store procedure
alter proc sp_DelayCount 
as
begin
return (select Count(*) from Orders where  RequiredDate <ShippedDate)
end

declare @Count int
exec @Count = sp_DelayCount
print (@Count)

-- Dışarıdan FirstName, LastName, Address ve City alan ona göre employee ekleyen store procedure
create proc sp_Employee (@firstname  nvarchar(max), @Lastname nvarchar(max),@adress nvarchar(max), @city nvarchar(max) )
as
begin 
insert into Employees(FirstName, LastName, Address, City)
values(@firstname, @Lastname, @adress, @city)
end 
--Dışarıdan Name alan ve aldığı name e göre bulduğu product ı silen store procedure. büyük küçük harf farketmemeli ( hata verecek!)

create proc Sp_delete (@name nvarchar (max))
as 
begin
if EXISTS(select * from Products where lower(ProductName) = lower(@name))
begin
delete from Products where lower(ProductName) = lower(@name)
end
end 
