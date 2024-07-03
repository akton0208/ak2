#  aleo-miner

### 版本号

2.4.6

### start

```
chmod +x aleo.sh && chmod +x aleo-miner
./aleo.sh stratum+tcp://aleo-asia.f2pool.com:4400 accountname.workername
```

If the GPU cannot be started successfully, use the following command

```
sh
nohup ./aleo-miner -u "stratum+tcp://aleo-asia.f2pool.com:4400" -w “accountname.workername“ -d 0 >> ./aleo-miner.log 2>&1 &
```

### parameter instruction

```
 -u, --url <URL>              Set the pool URL Format: <Working protocol>+<Wransport protocol>://<pool>:<port> Working protocol: stratum Transport protocols: tcp, ssl
 -w, --worker <WORKER>        Set the account && worker name [default: accountname.workername]
 -d, --devices <DEVICES>      -d 0
```
