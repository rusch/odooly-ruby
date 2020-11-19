Odooly-Ruby
===========

Lightweight library for browsing and manipulating Odoo / OpenERP data via the XMLRPC API.


How to use
------------

Initialization can be done either in class context or by instantiating an object. The class context way may be advantageous in a Ruby on Rails appication.

It is possible to us e both ways at the same time.

```ruby
Odooly.configure(scheme: 'http', host: 'localhost', port: 18069, username: 'thom', password: 'thom', database: 'behave')
```

or

```ruby
odooly=Odooly.new(scheme: 'http', host: 'localhost', port: 18069, username: 'thom', password: 'thom', database: 'behave')
```


Searching. After the initialization searching can be performed as shown in this exemplary irb session

```ruby
2.6.0 :001 > odooly=Odooly.new(scheme: 'http', host: 'localhost', port: 18069, username: 'thom', password: 'thom', database: 'behave')
 => <Odooly thom@behave>
2.6.0 :002 > customers = odooly['res.partner'].search(['last_name=Simpson'])
 => <Odooly::RecordList 'res.partner,[162, 161, 160, 18, 13, 12, 11]'>
2.6.0 :003 > pp customers.name
["Lisa Simpson",
 "Bart Simpson",
 "Homer Simpson",
 "Abraham Simpson",
 "Lisa Simpson",
 "Bart Simpson",
 "Homer Simpson"]
 => ["Lisa Simpson", "Bart Simpson", "Homer Simpson", "Abraham Simpson", "Lisa Simpson", "Bart Simpson", "Homer Simpson"]
2.6.0 :004 > customers.read(['first_name', 'last_name'])
 => [{"first_name"=>"Lisa", "last_name"=>"Simpson", "id"=>162}, {"first_name"=>"Bart", "last_name"=>"Simpson", "id"=>161}, {"first_name"=>"Homer", "last_name"=>"Simpson", "id"=>160}, {"first_name"=>"Abraham", "last_name"=>"Simpson", "id"=>18}, {"first_name"=>"Lisa", "last_name"=>"Simpson", "id"=>13}, {"first_name"=>"Bart", "last_name"=>"Simpson", "id"=>12}, {"first_name"=>"Homer", "last_name"=>"Simpson", "id"=>11}]
```

Updating values is done as follows:

```ruby
2.6.0 :005 > customers = odooly['res.partner'].search(['first_name=Abraham', 'last_name=Simpson'])[0]
 => <Odooly::Record 'res.partner,18'>
2.6.0 :006 > customer = odooly['res.partner'].search(['first_name=Abraham', 'last_name=Simpson'])[0]
 => <Odooly::Record 'res.partner,18'>
2.6.0 :007 > customer.write({'last_name': 'Lincoln'})
 => true
2.6.0 :008 > odooly['res.partner'].browse(18).name
 => "Abraham Lincoln"
```
