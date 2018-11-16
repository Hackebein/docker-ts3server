update clients set client_lastconnected=:client_lastconnected:, client_totalconnections=client_totalconnections+1 where client_id=:client_id: and server_id=:server_id:;
