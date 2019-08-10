#  某人實作案例
## 設備說明

1. Database：Master採用SQLServer，Client 1與Client 2是SQLServer，Client 3為Oracle。其中Master、Client 1與Client2均屬同一套SQLServer Express，但不同Database。
O/S：均是Centos。
1. Hardware：兩台Virtual-Machine。
1. sunserver master node: 192.168.122.101:1433
1. sun-client1 node: 192.168.122.101:1433
1. sun-client2 node: 192.168.122.101:1433
1. sun-client3 node: 192.168.122.102:1521


<img src=image1.png />

## 程式安裝
安裝方式很簡單，只要將壓縮檔解開後放到任意處即可。
在這次測試中，因為Master、Client1跟2都在同一台電腦上，但因為一個SymmetricDS服務對應一個Database，所以要分別安裝三份SymmetricDS以對應不同的DB。

## 系統設置
在[SymmetricDS Home]\samples目錄下有預先準備好的設置範例文件。複製corp-000.properties到[SymmetricDS Home]\engines，並改名為[engine_name].properties。

### 修改.properties檔，其內容有

1. engine.name：節點的名稱
1. db.driver：JDBC Driver名稱，安裝壓縮檔裡都已經有包含各資料庫的JDBC Driver。
1. db.url：JDBC Connection URL
1. db.user：資料庫用戶，此用戶必須要有建立、新增、修改、刪除權限，在這邊是偷懶用sa當用戶。
1. db.password：資料庫用戶密碼。
1. registration.url：上一級節點的註冊路徑，因為本節點為Master Node，所以此處沒有設定。
1. sync.url：本機的註冊路徑，當節點為最末端節點時，此處可以不用設定。
1. group.id：節點群組ID。
1. external.id：節點群組下的編號，group.id＋external.id等於辨識節點的唯一值。
1. 其他參數為三種同步方式預設的Period Time，沒有特別需求可以不用更動。

### Master Node配置

```properties
engine.name=sunserver-000
 
# The class name for the JDBC Driver
db.driver=net.sourceforge.jtds.jdbc.Driver
 
# The JDBC URL used to connect to the database
db.url=jdbc:jtds:sqlserver://192.168.122.101:1433/sun;instance=SQLEXPRESS
 
# The user to login as who can create and update tables
db.user=sa
 
# The password for the user to login as
db.password=1qaz2wsx#EDC
 
registration.url=
sync.url=http://192.168.122.101:8080/sync/sunserver-000
 
# Do not change these for running the demo
group.id=sunserver
external.id=000
 
# Don't muddy the waters with purge logging
job.purge.period.time.ms=7200000
 
# This is how often the routing job will be run in milliseconds
job.routing.period.time.ms=5000
# This is how often the push job will be run.
job.push.period.time.ms=10000
# This is how often the pull job will be run.
job.pull.period.time.ms=10000
# Kick off initial load
initial.load.create.first=true

Client 1 Node配置
engine.name=sunclient-001
 
# The class name for the JDBC Driver
db.driver=net.sourceforge.jtds.jdbc.Driver
 
# The JDBC URL used to connect to the database
db.url=jdbc:jtds:sqlserver://192.168.122.101:1433/sun1;instance=SQLEXPRESS
 
# The user to login as who can create and update tables
db.user=sa
 
# The password for the user to login as
db.password=1qaz2wsx#EDC
 
# The HTTP URL of the root node to contact for registration
registration.url=http://192.168.122.101:8080/sync/sunserver-000
sync.url=http://192.168.122.101:7070/sync/sunclient-001
 
 
# Do not change these for running the demo
group.id=sunclient
external.id=001
 
# This is how often the routing job will be run in milliseconds
job.routing.period.time.ms=5000
# This is how often the push job will be run.
job.push.period.time.ms=10000
# This is how often the pull job will be run.
job.pull.period.time.ms=10000

```

### Client 2 Node配置

```properties
engine.name=sunclient-002
 
# The class name for the JDBC Driver
db.driver=net.sourceforge.jtds.jdbc.Driver
 
# The JDBC URL used to connect to the database
db.url=jdbc:jtds:sqlserver://192.168.122.101:1433/sun2;instance=SQLEXPRESS
 
# The user to login as who can create and update tables
db.user=sa
 
# The password for the user to login as
db.password=1qaz2wsx
 
# The HTTP URL of the root node to contact for registration
registration.url=http://192.168.122.101:8080/sync/sunserver-000
sync.url=http://192.168.122.101:9090/sync/sunclient-002
# Do not change these for running the demo
group.id=sunclient
external.id=002
 
# This is how often the routing job will be run in milliseconds
job.routing.period.time.ms=5000
# This is how often the push job will be run.
job.push.period.time.ms=10000
# This is how often the pull job will be run.
job.pull.period.time.ms=10000
```

因為Master、Client 1和Client 2在同一台電腦上，所以在設定sync.url時需要用
不同的port區分開來，以避免衝突。

Client 3 Node配置

```properties
engine.name=sunclient-003
 
# The class name for the JDBC Driver
db.driver=oracle.jdbc.driver.OracleDriver
 
# The JDBC URL used to connect to the database
db.url=jdbc:oracle:thin:@192.168.122.102:1521:XE
 
# The user to login as who can create and update tables
db.user=apps
 
# The password for the user to login as
db.password=apps
 
registration.url=http://192.168.122.101:8080/sync/sunserver-000
sync.url=http://192.168.122.102:8888/sync/sunclient-003
 
# Do not change these for running the demo
group.id=sunclient
external.id=003
 
# Don't muddy the waters with purge logging
job.purge.period.time.ms=7200000
 
# This is how often the routing job will be run in milliseconds
job.routing.period.time.ms=5000
# This is how often the push job will be run.
job.push.period.time.ms=10000
# This is how often the pull job will be run.
job.pull.period.time.ms=10000
# Kick off initial load
initial.load.create.first=true
```


### Master Node初始化

#### Step 1.對Database進行初始化

使用Command Mode，進入[SymmectricDS Home]\engines，執行
..\bin\symadmin --engine sunserver-000 create-sym-tables
 sh ../bin/symadmin  --engine sunserver-000 create-sym-tables

執行後，會自動在資料庫中建立許多sym開頭的Table跟index。

#### Step 2.寫入Node Group

```sql
insert into sym_node_group (node_group_id, description) values ('sunserver', '主要資料中心');

insert into sym_node_group (node_group_id, description) values ('sunclient', '次要資料中心');
```

#### Step 3.設定Node Group之間的資料同步方式

1. 由data_event_action來指定同步方式
1. P代表Push，W代表Wait for pull

```sql
insert into sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action)
 values ('sunclient', 'sunserver', 'P');

insert into sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action)
 values ('sunserver', 'sunclient', 'W');
```

#### Step 4.設定Node
1. sym_node_security是用來紀錄節點通訊前的驗證密碼，同時registration_time與initial_load_time的設定是用來讓系統知道這個節點已經註冊並初始化，不用在系統啟動時再做一次。
1. 僅需要註冊Master Node資訊，其他的Client Node會在註冊節點後自動寫入節點資訊。

#### Step 5.設定通道

```sql
insert into sym_channel(channel_id, processing_order, max_batch_size, enabled, description)
 values('bus_info', 1, 100000, 1, '資料同步通道';
```

#### Step 6.定義Trigger

1. 定義要同步的Table Name。
1. 當有設定Foreign Key的Table需要設定在同一個Channel。
1. Sym_trigger中的excluded_column_names column可以排除不想同步的欄位。

```sql
insert into sym_trigger
(trigger_id,source_table_name,channel_id,last_update_time,create_time)
values('symmetric_test_area','symmetric_test_area','bus_info',current_timestamp,current_timestamp);
 
insert into sym_trigger 
(trigger_id,source_table_name,channel_id,last_update_time,create_time)
values('symmetric_test_bus','symmetric_test_bus','bus_info',current_timestamp,current_timestamp);
```


#### Step 7.定義Router
1. 設定資料同步的走向，即是資料從哪個節點流向那個節點。
1. 當Router_Type='Column'時表示可以從來源Table的特定欄位值來決定資料的流向，可以在Router_Expression欄位中指定表達式[Example:ORG_CODE=:EXTERNAL_ID]

```sql
insert into sym_router
(router_id,source_node_group_id,target_node_group_id,router_type,create_time,last_update_time)
values('client_2_server', 'sunclient', 'sunserver', 'default',current_timestamp, current_timestamp);
```


#### Step 8.建立Trigger與Router的關連

Trigger只有被Router關連後，SymmetricDS才會為這個Table自動建立對應的觸發器。

```sql
insert into sym_trigger_router
(trigger_id,router_id,initial_load_order,last_update_time,create_time)
values('symmetric_test_area','client_2_server', 200, current_timestamp, current_timestamp);
 
insert into sym_trigger_router
(trigger_id,router_id,initial_load_order,last_update_time,create_time)
values('symmetric_test_bus','client_2_server', 200, current_timestamp, current_timestamp);
```

### 啟動SymmetricDS
#### Step 1.註冊Client Node
1. 只有第一次使用才需要註冊
1. 使用Command Mode進入[Master Node SymmetricDS Home]/engines
執行註冊命令

```power64
..\bin\symadmin --engine sunserver-000 open-registration sunclient 001
..\bin\symadmin --engine sunserver-000 open-registration sunclient 002
..\bin\symadmin --engine sunserver-000 open-registration sunclient 003
```

```bash
 sh ../bin/symadmin  --engine sunserver-000   open-registration   sunclient   001
 sh ../bin/symadmin  --engine sunserver-000   open-registration   sunclient   002
 sh ../bin/symadmin  --engine sunserver-000   open-registration   sunclient   003
```

#### Step 2.啟動服務
##### 啟動Client Node
使用Command Mode進入[Client Node SymmetricDS Home]/engines
輸入 sym –port 7070
```bash
sh ../bin/sym -port  7070
sh ../bin/sym -port  8888
```

##### 啟動Master Node
使用Command Mode進入[Master Node SymmetricDS Home]/engines
輸入 sym –port 8080

```bash
sh ../bin/sym -port  8080
```

這裡指定的Port需跟properties裡sync.url設定的Port一樣

###實作結果

<img src=image2.png />
