Odooly-Ruby
===========


How to use

```ruby
2.6.0 :001 > require 'odooly'
 => true
2.6.0 :002 > odooly=Odooly.new(
2.6.0 :003 >       scheme: 'http',
2.6.0 :004 >       host: 'localhost',
2.6.0 :005 >       port: 18069,
2.6.0 :006 >       username: 'thom',
2.6.0 :007 >       password: 'thom',
2.6.0 :008 >       database: 'behave')
 => <Odooly thom@behave>
2.6.0 :009 > customers = odooly['res.partner'].search(['last_name=Simpson'])
 => <Odooly::RecordList 'res.partner,length=13'>
2.6.0 :010 > customers.name
 => ["Lisa Simpson", "Bart Simpson", "Homer Simpson", "Lisa Simpson", "Bart Simpson", "Homer Simpson", "Lisa Simpson", "Bart Simpson", "Homer Simpson", "Abraham Simpson", "Lisa Simpson", "Bart Simpson", "Homer Simpson"]
2.6.0 :011 > customers.read(['first_name', 'last_name'])
 => [{"first_name"=>"Lisa", "last_name"=>"Simpson", "id"=>463}, {"first_name"=>"Bart", "last_name"=>"Simpson", "id"=>462}, {"first_name"=>"Homer", "last_name"=>"Simpson", "id"=>461}, {"first_name"=>"Lisa", "last_name"=>"Simpson", "id"=>460}, {"first_name"=>"Bart", "last_name"=>"Simpson", "id"=>459}, {"first_name"=>"Homer", "last_name"=>"Simpson", "id"=>458}, {"first_name"=>"Lisa", "last_name"=>"Simpson", "id"=>457}, {"first_name"=>"Bart", "last_name"=>"Simpson", "id"=>456}, {"first_name"=>"Homer", "last_name"=>"Simpson", "id"=>455}, {"first_name"=>"Abraham", "last_name"=>"Simpson", "id"=>18}, {"first_name"=>"Lisa", "last_name"=>"Simpson", "id"=>13}, {"first_name"=>"Bart", "last_name"=>"Simpson", "id"=>12}, {"first_name"=>"Homer", "last_name"=>"Simpson", "id"=>11}]


2.6.0 :012 > odooly['wingo.contract.task'].add_comment_yaml({'task_id' => 156, 'comment' => "test123", user: 'dagobert.duck'}.to_yaml)
 => "reason_code: '0'\n"
```