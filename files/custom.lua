-- Copyright 2018 Erlio GmbH Basel Switzerland (http://erl.io)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

-- MySQL Configuration, read the documentation below to properly
-- provision your database.
require "auth/auth_commons"
local jwt = require "auth/luajwt/luajwt" --[[
--
   INSERT INTO vmq_auth_acl 
   (mountpoint, client_id, username, 
    password, publish_acl, subscribe_acl)
 VALUES 
   ('', 'test-client', 'test-user', 
    PASSWORD('123'), '[{"pattern":"a/b/c"},{"pattern":"c/b/#"}]', 
                     '[{"pattern":"a/b/c"},{"pattern":"c/b/#"}]');
]] -- NOTE THAT `PASSWORD()` NEEDS TO BE SUBSTITUTED ACCORDING TO THE HASHING METHOD -- 	allowed for this particular user. MQTT wildcards as well as the variable -- CONFIGURED IN `vmq_diversity.mysql.password_hash_method`. CHECK THE MYSQL DOCS TO -- 	substitution for %m (mountpoint), %c (client_id), %u (username) are allowed -- FIND THE MATCHING ONE AT https://dev.mysql.com/doc/refman/8.0/en/encryption-functions.html. -- 	inside a pattern. -- -- -- -- -- IF YOU USE THE SCHEMA PROVIDED ABOVE NOTHING HAS TO BE CHANGED IN THE -- FOLLOWING SCRIPT.
-- -- To insert a client ACL use a similar SQL statement: -- 	The JSON array passed as publish/subscribe ACL contains the topic patterns
--
--        results = mysql.execute(pool,ttern="activity/+/message", max_qos=1}
-- In order to use this Lua plugin you must deploy the following database
-- schema and grant the user configured above with the required privileges:
--[[ 
   CREATE TABLE vmq_auth_acl
   (
     mountpoint VARCHAR(10) NOT NULL,
     client_id VARCHAR(128) NOT NULL,
     username VARCHAR(128) NOT NULL,
     password VARCHAR(128),
     publish_acl TEXT,
     subscribe_acl TEXT,
     CONSTRAINT vmq_auth_acl_primary_key PRIMARY KEY (mountpoint, client_id, username)
   )
  ]] 
  
function auth_on_register(reg)
  if reg.username == "cRqlmWsryumZvmO3bs0Nc2DMiyv0t9L1" and reg.password == "tbSSYbQP8LkaCcANOf628f3Vlkdvdym5" then
    client = mysplit(reg.client_id)
    client_id = client[1]
    auth_token = client[2]
    local decoded, err = jwt.decode(auth_token, "qwoureceroi23012dflkjeroi23238007", true)
    if err then
      return false
    end
    if (client_id == nil) then
      return false
    end
    if (auth_token == nil) then
      auth_token = "GUEST"
    end
    if not decoded["user_uid"] then
      publish_acl = {
        {pattern = "activity/+/message", max_qos = 1},
        {pattern = "activity/+/follow", max_qos = 1},
        {pattern = "stream_stats/+/watch", max_qos = 1},
        {pattern = "all/+/device_disconnect", max_qos = 1},
        {pattern = "chat/+/device", max_qos = 1},
        {pattern = "device-ping", max_qos = 1},
        {pattern = "stream_stats/+/device", max_qos = 1}
      }
      subscribe_acl = {
        {pattern = "chat/+/message", max_qos = 1},
        {pattern = "activity/+/message", max_qos = 1},
        {pattern = "activity/+/follow", max_qos = 1},
        {pattern = "chat/+/+/history", max_qos = 1},
        {pattern="chat/+/device", max_qos=1},
        {pattern = "stream_stats/+/live_views", max_qos = 1}
      }
      mount_point = ""
      cache_insert(mount_point, reg.client_id, reg.username, publish_acl, subscribe_acl)
      return true
    end
    publish_acl = {
      {pattern = "stream_stats/+/watch", max_qos = 1},
      {pattern = "activity/+/message", max_qos = 1},
      {pattern = "activity/+/follow", max_qos = 1},
      {pattern = "all/+/device_disconnect", max_qos = 1},
      {pattern = "chat/+/device", max_qos = 1},
      {pattern = "device-ping", max_qos = 1},
      {pattern = "chat/+/message", max_qos = 1, modifiers = {throttle = 1000}},
      {pattern = "stream_stats/+/device", max_qos = 1}
    }
    subscribe_acl = {
      {pattern = "activity/+/message", max_qos = 1},
      {pattern = "activity/+/follow", max_qos = 1},
      {pattern = "stream_stats/+/watch", max_qos = 1},
      {pattern = "chat/+/message", max_qos = 1},
      {pattern="chat/+/device", max_qos=1},
      {pattern = "chat/+/+/history", max_qos = 1},
      {pattern = "stream_stats/+/live_views", max_qos = 1}
    }
    mount_point = ""
    cache_insert(mount_point, reg.client_id, reg.username, publish_acl, subscribe_acl)
    return true
  elseif reg.username == "1QGlx7a5OFdtigW4yuso6aH16cJvksyL" and reg.password == "kNfQZkklRofQaF3v2r9mZXncKriPPPcR" then
    publish_acl = {
      {pattern = "activity/+/follow", max_qos = 1},
      {pattern = "chat/+/+/history", max_qos = 1},
      {pattern = "stream_stats/+/live_views", max_qos = 1}
    }
    subscribe_acl = {
      {pattern = "all/+/device_disconnect", max_qos = 1},
      {pattern = "$share/sharename/chat/+/message", max_qos = 1},
      {pattern = "$share/sharename/chat/+/device", max_qos = 1},
      {pattern = "$share/sharename/stream_stats/+/device", max_qos = 1}
    }
    mount_point = ""
    cache_insert(mount_point, reg.client_id, reg.username, publish_acl, subscribe_acl)
    return true
  else
    return false
  end
end

function mysplit(str, sep)
  if sep == nil then
    sep = ":"
  end

  local res = {}
  local func = function(w)
    table.insert(res, w)
  end

  string.gsub(str, "[^" .. sep .. "]+", func)
  return res
end
--function mysplit(inputstr, sep)
--        if sep == nil then
--                sep = ":"
--        end
--        local t={}
--        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
--                table.insert(t, str)
--        end
--        return t
--end
-- function auth_on_publish(pub)
--   return next
-- end
--    return true
--end
--pool = "auth_custom"
--config = {
--    pool_id = pool
--}

--custom.ensure_pool(config)
hooks = {
  auth_on_register = auth_on_register
}