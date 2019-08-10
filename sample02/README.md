#  某人實作案例
來源
https://github.com/UKHomeOffice/docker-symmetricds

## 操作說明

```bash
[robert0714@1204003PC01 docker-symmetricds]$ docker-compose -f docker-compose-mysql.yml   up -d
[robert0714@1204003PC01 docker-symmetricds]$ docker exec -it  docker-symmetricds_symds_source_1  rm -rf  /app/symmetric-server/lib/mysql-connector-java-*.jar
[robert0714@1204003PC01 docker-symmetricds]$ wget  https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.17/mysql-connector-java-8.0.17.jar
[robert0714@1204003PC01 docker-symmetricds]$ docker cp  mysql-connector-java-8.0.17.jar  docker-symmetricds_symds_source_1:/app/symmetric-server/lib/

[robert0714@1204003PC01 docker-symmetricds]$ docker restart   docker-symmetricds_symds_source_1   

[robert0714@1204003PC01 docker-symmetricds]$ docker exec -it  docker-symmetricds_symds_source_1  /bin/bash
[symds@c9c9b7f5665c app]$ cd symmetric-server/lib/


```

## entrypoint.sh 特別內容

```bash

# Configure according to environment variables
cat << EOL > "./conf/symmetric-server.properties"
rest.api.enable=true
host.bind.name=${LISTEN_HOST}
http.enable=${HTTP_ENABLE}
http.port=${HTTP_PORT}
https.enable=${HTTPS_ENABLE}
https.port=${HTTPS_PORT}
https.allow.self.signed.certs=false
jmx.http.enable=false
jmx.http.port=31416
EOL

cat << EOL > "./conf/log4j.xml"
<?xml version="1.0" encoding="UTF-8"?>
<!--

    Licensed to JumpMind Inc under one or more contributor
    license agreements.  See the NOTICE file distributed
    with this work for additional information regarding
    copyright ownership.  JumpMind Inc licenses this file
    to you under the GNU General Public License, version 3.0 (GPLv3)
    (the "License"); you may not use this file except in compliance
    with the License.

    You should have received a copy of the GNU General Public License,
    version 3.0 (GPLv3) along with this library; if not, see
    <http://www.gnu.org/licenses/>.

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.

-->
<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd">

<log4j:configuration xmlns:log4j="http://jakarta.apache.org/log4j/" debug="false">

    <appender name="ROLLING" class="org.jumpmind.util.SymRollingFileAppender">
        <param name="File" value="\${log4j.sym.home}/logs/symmetric.log" />
        <param name="MaxFileSize" value="20MB" />
        <param name="MaxBackupIndex" value="3" />
        <param name="Append" value="true" />
        <layout class="org.jumpmind.symmetric.web.SymPatternLayout">
            <param name="ConversionPattern" value="%d %p [%X{engineName}] [%c{1}] [%t] %m%n" />
        </layout>
    </appender>

    <appender name="CONSOLE" class="org.apache.log4j.ConsoleAppender">
        <param name="Target" value="System.err" />
        <layout class="org.jumpmind.symmetric.web.SymPatternLayout">
            <param name="ConversionPattern" value="%d{ISO8601} %p: [%X{engineName}] - %c{1} - %m%n" />
        </layout>
    </appender>

    <appender name="BUFFERED" class="org.jumpmind.util.BufferedLogAppender"/>

    <!-- Uncomment to send errors over email.  (1/2) -->
    <!--
    <appender name="EMAIL" class="org.apache.log4j.net.SMTPAppender">
        <param name="SMTPHost" value="mymailhost" />
        <param name="SMTPUsername" value="" />
        <param name="SMTPPassword" value="" />
        <param name="From" value="user@nowhere" />
        <param name="To" value="user@nowhere" />
        <param name="Subject" value="Error from SymmetricDS" />
        <param name="BufferSize" value="10" />
        <param name="LocationInfo" value="true" />
        <layout class="org.apache.log4j.PatternLayout">
            <param name="ConversionPattern" value="%t %m%n"/>
        </layout>
        <filter class="org.apache.log4j.varia.LevelRangeFilter">
            <param name="LevelMin" value="error" />
            <param name="LevelMax" value="fatal" />
        </filter>
    </appender>
    -->

    <category name="org">
        <priority value="${LOG_LEVEL}" />
    </category>

    <category name="org.jumpmind">
        <priority value="${SYMDS_LOG_LEVEL}" />
    </category>

    <category name="com.mangofactory.swagger.filters.AnnotatedParameterFilter">
        <priority value="ERROR" />
    </category>

    <category name="oracle.jdbc">
        <priority value="${DATA_LOG_LEVEL}" />
    </category>
    <category name="org.mysql">
        <priority value="${DATA_LOG_LEVEL}" />
    </category>
    <category name="org.postgresql">
        <priority value="${DATA_LOG_LEVEL}" />
    </category>
    <category name="org.jumpmind.db">
        <priority value="${DATA_LOG_LEVEL}" />
    </category>
    <category name="org.jumpmind.db.sql">
        <priority value="${DATA_LOG_LEVEL}" />
    </category>
    <category name="org.jumpmind.db.platform">
        <priority value="${DATA_LOG_LEVEL}" />
    </category>
    <category name="org.jumpmind.symmetric.io.data">
        <priority value="${DATA_LOG_LEVEL}" />
    </category>
    <category name="org.jumpmind.symmetric.db">
        <priority value="${DATA_LOG_LEVEL}" />
    </category>
    <category name="org.jumpmind.symmetric.db.SqlScript">
        <priority value="${DATA_LOG_LEVEL}" />
    </category>

    <!-- Disable the not found override properties file warnings to avoid confusion -->
    <category name="org.jumpmind.symmetric.util.PropertiesFactoryBean">
        <priority value="ERROR" />
    </category>

    <category name="org.jumpmind.symmetric.service.impl.ParameterService">
        <priority value="ERROR" />
    </category>

    <category name="org.springframework">
        <priority value="ERROR" />
    </category>

    <category name="com.vaadin.server.DefaultDeploymentConfiguration">
        <priority value="ERROR" />
    </category>

    <category name="com.vaadin.event.ConnectorActionManager">
        <priority value="ERROR" />
    </category>

    <category name="com.vaadin.server.communication">
        <priority value="FATAL" />
    </category>

    <category name="org.atmosphere">
        <priority value="FATAL" />
    </category>

    <!-- Uncomment to see CSV protocol from sending batches -->
    <!--
    <category name="org.jumpmind.symmetric.io.data.writer.ProtocolDataWriter">
        <priority value="DEBUG"/>
    </category>
    -->

    <!-- Uncomment to see SQL statements from loading batches -->
    <!--
    <category name="org.jumpmind.symmetric.io.data.writer.DefaultDatabaseWriter">
        <priority value="DEBUG" />
    </category>
    -->

    <!-- Enable this to see debug messages in JMS publishing extensions -->
    <!--
    <category name="org.jumpmind.symmetric.integrate">
        <priority value="DEBUG" />
    </category>
    -->

    <!-- Enable this to see debug messages for why SymmetricDS tables are being altered -->
    <!--
    <category name="org.jumpmind.db.alter">
        <priority value="DEBUG" />
    </category>
    -->

    <!-- In order to see http headers enable this, and also edit logging.properties
    <category name="sun.net.www.protocol.http.HttpURLConnection">
        <priority value="ALL" />
    </category>
     -->

    <!-- Change the "CONSOLE" to "ROLLING" to log to a file instead -->
    <root>
        <priority value="${LOG_LEVEL}" />
        <appender-ref ref="CONSOLE" />
        <!--
        <appender-ref ref="ROLLING" />
        <appender-ref ref="BUFFERED" />
        -->
        <!-- Uncomment to send errors over email. (2/2) -->
        <!--
        <appender-ref ref="EMAIL" />
        -->
    </root>

</log4j:configuration>
EOL

cat << EOL > "./engines/${ENGINE_NAME}-${EXTERNAL_ID}.properties"
rest.api.enable=true
engine.name=${ENGINE_NAME}
group.id=${GROUP_ID}
external.id=${EXTERNAL_ID}
sync.url=${SYNC_URL}
registration.url=${REGISTRATION_URL}
db.driver=${JDBC_DRIVER}
db.url=${JDBC_URL}
db.user=${DB_USER}
db.password=${DB_PASS}
EOL

if [[ -n "${REPLICATE_TO}" ]]; then
  cat << EOL >> "./engines/${ENGINE_NAME}-${EXTERNAL_ID}.properties"
initial.load.create.first=true
EOL
fi

if [[ -n "${USERNAME}" && -n "${PASSWORD}" ]]; then
  # basic auth setup!!
  sed -i "s|</web-app>|<security-constraint><web-resource-collection><url-pattern>/*</url-pattern></web-resource-collection><auth-constraint><role-name>user</role-name></auth-constraint></security-constraint><login-config><auth-method>BASIC</auth-method><realm-name>default</realm-name></login-config></web-app>|" ./web/WEB-INF/web.xml

  echo -n "${USERNAME}: ${PASSWORD},user" >> ./web/WEB-INF/realm.properties

  echo -e "<Configure class=\"org.eclipse.jetty.webapp.WebAppContext\"> \n
<Get name=\"securityHandler\"> \n
<Set name=\"loginService\"> \n
<New class=\"org.eclipse.jetty.security.HashLoginService\"> \n
<Set name=\"name\">default</Set> \n
<Set name=\"config\"><SystemProperty name=\"user.dir\" default=\".\"/>/web/WEB-INF/realm.properties</Set> \n
</New> \n
</Set> \n
</Get> \n
</Configure>" >> ./web/WEB-INF/jetty-web.xml

  cat << EOL >> "./engines/${ENGINE_NAME}-${EXTERNAL_ID}.properties"
http.basic.auth.username=${USERNAME}
http.basic.auth.password=${PASSWORD}
EOL
  #end of basic auth setup
fi

echo "Waiting for database at ${DB_HOST}:${DB_PORT}..."
nc="nc ${DB_HOST} ${DB_PORT} </dev/null 2>/dev/null"
set +e
eval ${nc}
while [ $? -ne 0 ]; do
  echo ...
  sleep 5
  eval ${nc}
done

if [[ -n "${REPLICATE_TO}" ]]; then
  echo "Initialising config in ${DB_TYPE}..."
  cat << EOL > "init.sql"
insert into sym_node_group
        (node_group_id)
        values ('${REPLICATE_TO}');

insert into sym_node_group_link
(source_node_group_id, target_node_group_id, data_event_action)
      values ('${REPLICATE_TO}', '${GROUP_ID}', 'P');

insert into sym_node_group_link
(source_node_group_id, target_node_group_id, data_event_action)
      values ('${GROUP_ID}', '${REPLICATE_TO}', 'W');

insert into sym_router (router_id,
        source_node_group_id, target_node_group_id, create_time,
        last_update_time) values ('${GROUP_ID}-2-${REPLICATE_TO}','${GROUP_ID}', '${REPLICATE_TO}',
        current_timestamp, current_timestamp);
EOL

  for REPLICATE_TABLE in $REPLICATE_TABLES; do
    if [[ $REPLICATE_TABLE == *"|"* ]]; then
      echo 'Found cols in table config'
      REPLICATE_COLS=${REPLICATE_TABLE#*|}
      REPLICATE_TABLE=${REPLICATE_TABLE%|*}
      echo "REPLICATE_TABLE=$REPLICATE_TABLE and REPLICATE_COLS=$REPLICATE_COLS"
    fi

    echo "Adding config for $REPLICATE_TABLE in ${DB_TYPE}..."
    cat << EOL >> "init.sql"
insert into sym_channel
(channel_id, processing_order, max_batch_size, max_batch_to_send, extract_period_millis, batch_algorithm, enabled)
      values ('${REPLICATE_TABLE}', 10, 1000, 10, 0, 'default', 1);

insert into sym_trigger
(trigger_id, source_table_name, channel_id, last_update_time, create_time, included_column_names)
      values ('${REPLICATE_TABLE}', '${REPLICATE_TABLE}', '${REPLICATE_TABLE}', current_timestamp, current_timestamp, '${REPLICATE_COLS}');

insert into sym_trigger_router
(trigger_id, router_id, initial_load_order, create_time, last_update_time)
      values ('${REPLICATE_TABLE}', '${GROUP_ID}-2-${REPLICATE_TO}', 1, current_timestamp, current_timestamp);
EOL
  done

  ./bin/symadmin --engine "${GROUP_ID}" create-sym-tables
  ./bin/dbimport --engine "${GROUP_ID}" "init.sql"
  rm "init.sql"
  echo "Opening registration for '${REPLICATE_TO}'..."
  ./bin/symadmin --engine "${GROUP_ID}" open-registration "${REPLICATE_TO}" "${REPLICATE_TO}"
  echo "Setting up initial load for '${REPLICATE_TO}'..."
  ./bin/symadmin --engine "${GROUP_ID}" reload-node "${REPLICATE_TO}"
fi

# Start SymmetricDS
echo "Starting SymmetricDS..."
exec "./bin/sym"


```