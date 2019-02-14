using System;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using System.Net;
using System.IO;
using System.Threading;
using System.Windows.Forms;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using RabbitMQ.Client.MessagePatterns;
using RabbitMQ.Client.Exceptions;
using XiaoP.Classes.Util;

namespace XiaoP.Classes.RabbitMQ
{
    public class RabbitMQHelper : IDisposable
    {

        private static string requestQueueName = "rpc_queue";

        private ConnectionFactory connectionFactory;

        //private static int MAX_TRY_TIMES = 20;

	    public RabbitMQHelper(){
            this.initConnection();
        }

        /*
        public RabbitMQHelper(string uri)
        {
            this.uri = uri;
            this.initConnection();
        }*/


        public RabbitMQHelper(string hostName)
        {
            this.hostName = hostName;
            this.initConnection();
        }

        public RabbitMQHelper(string hostName, string vhost, string userName, string password)
        {
            this.hostName = hostName;
            this.vhost = vhost;
            this.userName = userName;
            this.password = password;
            this.initConnection();
        }

        public RabbitMQHelper(string hostName, int port, string vhost, string userName, string password)
        {
            this.hostName = hostName;
            this.port = port;
            this.vhost =vhost;
            this.userName = userName;
            this.password = password;
            this.initConnection();
        }


        private void initConnection()
        {
            connectionFactory = new ConnectionFactory();
            if (this.uri != null)
            {
                connectionFactory.Uri = this._uri;
            }
            else {
                connectionFactory.HostName = this._hostName;

                connectionFactory.Port = this._port;
                if (this._vhost != null)
                    connectionFactory.VirtualHost = this._vhost;
                if (this._userName != null)
                    connectionFactory.UserName = this._userName;
                if (this._password != null)
                    connectionFactory.Password = this._password;
            }
            
            connectionFactory.RequestedHeartbeat = this._requestedHeartbeat; 

        }

     
        private bool _Cancelled = false;

        public bool Cancelled
        {
            get { return _Cancelled; }
            set { _Cancelled = value; }
        }
        
        public bool receive(Exchange exchange, Queue queue, string routingKey, Action<byte[]> handler)
        { 
            
             try
             {
                 using (IConnection connection =
                         connectionFactory.CreateConnection())
                 {
                     using (IModel model = connection.CreateModel())
                     {

                         model.ExchangeDeclare(exchange.name, exchange.type, exchange.durable, exchange.autoDelete, null);
                         model.BasicQos(0, 1, false);
                         model.QueueDeclare(queue.name, queue.durable, queue.exclusive, queue.autoDelete, null);

                         model.QueueBind(queue.name, exchange.name, routingKey);

                         
                         //QueueingBasicConsumer consumer =  new QueueingBasicConsumer(ch);
                         //model.BasicConsume(queue.name, true, consumer);

                       // while (true) {

                         //   try
                           // {
                             //   BasicDeliverEventArgs e = (BasicDeliverEventArgs)Consumer.Queue.Dequeue();
                            //}catch(Exception ex){
                                
                            //}
                                //IBasicProperties properties = e.BasicProperties;
                            //byte[] body = e.Body;
                            //handler(e.Body);
                            //Console.WriteLine("Recieved Message : " + Encoding.UTF8.GetString(body));
                            //model.BasicAck(e.DeliveryTag, false);
                        //}

                         
                         using (Subscription sub = new Subscription(model, queue.name, false))
                         {
                             
                             foreach (BasicDeliverEventArgs ev in sub)
                             {
                                 //if (this._Cancelled)
                                 //    break;
                                 sub.Ack();

                                 try
                                 {
                                     handler(ev.Body);
                                 }
                                 catch (Exception ex) {
                                     PLog.Exception(ex);                                         
                                 
                                 }
                             }
                             
                         }
                     }
                 }
             }
             catch (Exception ex)
             {
                 PLog.Exception(ex);
             }

             return true;
        }
        

        IConnection _connection = null;
        IModel _channel = null;
        Subscription _subscription = null;

        /*
        public void receive(Exchange exchange, Queue queue, string routingKey, Action<byte[]> handler)
        {
            int tryTimes = 0;
            while (!this._Cancelled)
            {
                try
                {
                    if (_subscription == null)
                    {
                        try
                        {
                            _connection = connectionFactory.CreateConnection();
                        }
                        catch (BrokerUnreachableException)
                        {
                            //You probably want to log the error and cancel after N tries, 
                            //otherwise start the loop over to try to connect again after a second or so.
                            tryTimes++;
                            if (tryTimes > MAX_TRY_TIMES)
                            {
                                return ;
                            }
                            continue;
                        }
                       

                        _channel = _connection.CreateModel();
                            
                        _channel.ExchangeDeclare(exchange.name, exchange.type, exchange.durable, exchange.autoDelete, null);
                        _channel.BasicQos(0, 1, false);

                        _channel.QueueDeclare(queue.name, queue.durable, queue.exclusive, queue.autoDelete, null);
                      
                        _channel.QueueBind(queue.name, exchange.name, routingKey);
                        _subscription = new Subscription(_channel, queue.name, false);
                    }


                    tryTimes = 0;
                    BasicDeliverEventArgs args;
                    bool gotMessage = _subscription.Next(250, out args);
                    if (gotMessage)
                    {
                        if (args == null)
                        {
                            //This means the connection is closed.
                            DisposeAllConnectionObjects();
                            continue;
                        }

                        handler(args.Body);
                        if (_subscription!=null)
                            _subscription.Ack(args);
                    }
                }
                catch (OperationInterruptedException ex)
                {
                    PLog.Exception(ex);
                    DisposeAllConnectionObjects();
                }
                
            }

            DisposeAllConnectionObjects();
        }*/

        /*
        public bool receive(Exchange exchange, Action<byte[]> handler)
        {
            int tryTimes = 0;
            while (true)
            {
                if (this._Cancelled)
                {
                    DisposeAllConnectionObjects();
                    return false;
                }

                Thread.Sleep(0);

                try
                {
                    if (_subscription == null)
                    {
                        //Console.Write("++++++++new connnection\n");
                        try
                        {
                            _connection = connectionFactory.CreateConnection();
                        }
                        catch (BrokerUnreachableException)
                        {
                            //You probably want to log the error and cancel after N tries, 
                            //otherwise start the loop over to try to connect again after a second or so.

                            tryTimes++;
                            if (tryTimes > MAX_TRY_TIMES)
                            {
                                return false;
                            }
                            continue;
                        }

                        _channel = _connection.CreateModel();

                        _channel.ExchangeDeclare(exchange.name, exchange.type, exchange.durable, exchange.autoDelete, null);
                        _channel.BasicQos(0, 1, false);

                        string queueName = _channel.QueueDeclare().QueueName;

                        _channel.QueueBind(queueName, exchange.name, "");
                        _subscription = new Subscription(_channel, queueName, false);
                    }


                    tryTimes = 0;
                    BasicDeliverEventArgs args;
                    bool gotMessage = _subscription.Next(250, out args);
                    if (gotMessage)
                    {
                        if (args == null)
                        {
                            //This means the connection is closed.
                            DisposeAllConnectionObjects();
                            continue;
                        }

                        handler(args.Body);
                        if (_subscription != null)
                            _subscription.Ack(args);
                    }
                }
                catch (OperationInterruptedException ex)
                {
                    PLog.Exception(ex);
                    DisposeAllConnectionObjects();
                }

            }

        }*/

        private void DisposeAllConnectionObjects()
        {
            if (_subscription != null)
            {
                //IDisposable is implemented explicitly for some reason.
                ((IDisposable)_subscription).Dispose();
                _subscription = null;
            }

            if (_channel != null)
            {
                _channel.Dispose();
                _channel = null;
            }

            if (_connection != null)
            {
                try
                {
                    _connection.Dispose();
                }
                catch (EndOfStreamException)
                {
                }
                _connection = null;
            }

            GC.Collect();
        }

        /*
        public delegate void myInvoke(Notice notice);

        public void receiveMsg(MainForm mainForm, MethodInvoker mi)
        {
             
            ConnectionFactory connectionFactory = new ConnectionFactory();
            connectionFactory.Uri = this.uri;
            try
            {
                using (IConnection connection =
                        connectionFactory.CreateConnection())
                {
                    using (IModel model = connection.CreateModel())
                    {
                        //ExchangeType.Fanout
                        //model.ExchangeDelete(this.exchangeName);

                        //model.ExchangeDeclare(this.exchangeName,this.exchangeType , true); 
                        model.QueueDeclare(this.queueName, false, false, false, new Dictionary<string, object>());

                        using (Subscription sub = new Subscription(model, queueName))
                        {
                            foreach (BasicDeliverEventArgs ev in sub)
                            {
                                mainForm.BeginInvoke(mi);   
          
                                    Console.WriteLine("Message : {0}", messageText(ev));

                                    sub.Ack();
                                }
                            }

                        
                    }
                }
            }
            catch (Exception ex)
            {

                Console.Write(ex.Message);
            }

        }
        */
        /*
        private static string messageText(BasicDeliverEventArgs ev)
        {
            return Encoding.UTF8.GetString(ev.Body);
        }*/

        private static string messageText(BasicDeliverEventArgs ev)
        {
            return Encoding.UTF8.GetString(ev.Body);

        }

        public static void execute(string typeName,string method,Object[] parameters){

            try
            {
                Type type = Type.GetType(typeName);
                MethodInfo methodInfo = type.GetMethod(method);

                //obj = ass.CreateInstance(typeName);


                //method.Invoke(obj, parameters);
                methodInfo.Invoke(null, parameters);

                // t.InvokeMember("setBottleProducer", BindingFlags.InvokeMethod, null, OpenerForm, new object[] { });
        
            }
            catch (Exception ex) {

                Console.Write(ex.Message);    
            
            }
            
        }


        /// <summary>
        /// 发送
        /// </summary>
        /// <param name="exchange"></param>
        /// <param name="queue"></param>
        /// <param name="routingKey"></param>
        /// <param name="message"></param>
        /// <returns></returns>
        public bool send(Exchange exchange, Queue queue, string routingKey, string message)
        {

            byte[] body = Encoding.UTF8.GetBytes(message);
            return send(exchange,queue,routingKey,body);
        }

        public bool send(Exchange exchange, Queue queue, string routingKey, string message, string encoding)
        {
            byte[] body = Encoding.UTF8.GetBytes(message);
            return send(exchange, queue, routingKey, body);
        }

        public bool send(Exchange exchange,byte[] body)
        {
            bool succ = false;

            try
            {
                using (IConnection connection =
                        connectionFactory.CreateConnection())
                {
                    using (IModel model = connection.CreateModel())
                    {

                        model.ExchangeDeclare(exchange.name, exchange.type,exchange.durable,exchange.autoDelete,null);
                        // model.BasicQos(0, 1, false);
                        //model.QueueDeclare(queueName, true, false, false, new Dictionary<string, object>());
                        //model.QueueDeclare(queueName, true, false, false, null);
                        //model.QueueDeclare(queue.name, queue.durable, queue.exclusive, queue.autoDelete, null);

                        //queueName = model.QueueDeclare();
                        //model.QueueBind(queue.name, exchange.name, routingKey);

                        model.BasicPublish(exchange.name,
                                       "",
                                       null,
                                       body);

                        succ = true;
                    }
                }
            }
            catch (Exception ex)
            {
                PLog.Exception(ex);
            }

            return succ;

        }

        public bool send(Exchange exchange, Queue queue, string routingKey, byte[] body)
        {
            bool succ = false;

            try
            {
                using (IConnection connection =
                        connectionFactory.CreateConnection())
                {
                    using (IModel model = connection.CreateModel())
                    {

                        model.ExchangeDeclare(exchange.name, exchange.type);
                        // model.BasicQos(0, 1, false);
                        //model.QueueDeclare(queueName, true, false, false, new Dictionary<string, object>());
                        //model.QueueDeclare(queueName, true, false, false, null);
                        model.QueueDeclare(queue.name, queue.durable, queue.exclusive, queue.autoDelete, null);

                        //queueName = model.QueueDeclare();
                        model.QueueBind(queue.name, exchange.name, routingKey);

                        model.BasicPublish(exchange.name,
                                       routingKey,
                                       null,
                                       body);

                        succ = true;
                    }
                }
            }
            catch (Exception ex)
            {
                PLog.Exception(ex);
            }

            return succ;

        }


        public event EventHandler TimedOutHandler;
        public event EventHandler DisconnectedHandler;
        /// <summary>
        /// 发送request请求
        /// </summary>
        /// <param name="message"></param>
        /// <returns></returns>
        public string sendRequest(string message) { 
       
            string response = "";

            try
            {
                using (IConnection connection =
                        connectionFactory.CreateConnection())
                {
                    using (IModel model = connection.CreateModel())
                    {

                        string replyQueueName = model.QueueDeclare().QueueName;

                        QueueingBasicConsumer consumer = new QueueingBasicConsumer(model);
                        model.BasicConsume(replyQueueName, true, consumer);

                        string queueName = model.QueueDeclare();

                        using (Subscription m_subscription = new Subscription(model, queueName))
                        {
                             // Subscription m_subscription = new Subscription(model, queueName);

                            string correlationId = Guid.NewGuid().ToString();
                            IBasicProperties basicProperties = model.CreateBasicProperties();
                            basicProperties.CorrelationId = correlationId;
                            basicProperties.ReplyTo = m_subscription.QueueName;
                         
                           //发送请求
                            model.BasicPublish("", requestQueueName, basicProperties, Encoding.UTF8.GetBytes(message));
                           
                           BasicDeliverEventArgs reply;
                           //接受返回值                     
                           if (!m_subscription.Next(this._timeOut, out reply))
                           {
                               if (TimedOutHandler != null)
                                   TimedOutHandler(this, null);
                               return "";
                           }

                           if (reply == null)
                           {
                               if (DisconnectedHandler != null)
                                   DisconnectedHandler(this, null);
                               return "";
                           }

                           if (reply.BasicProperties.CorrelationId != correlationId)
                           {
                               throw new ProtocolViolationException
                                   (string.Format("Wrong CorrelationId in reply; expected {0}, got {1}",
                                                  correlationId,
                                                  reply.BasicProperties.CorrelationId));
                           }


                           response = Encoding.UTF8.GetString(reply.Body);
                           m_subscription.Ack(reply);
                         
                        }

                    }
                }
            }
            catch (Exception ex)
            {

                //MessageBox.Show(ex.Message);
                Console.Write(ex.Message);

            }
            return response;
        
        }

        /// <summary>
        /// 发送request请求
        /// </summary>
        /// <param name="message"></param>
        /// <returns></returns>
        public byte[] sendRequest(byte[] request)
        {

            byte[] response = null;

            try
            {
                using (IConnection connection =
                        connectionFactory.CreateConnection())
                {
                    using (IModel model = connection.CreateModel())
                    {

                        string replyQueueName = model.QueueDeclare().QueueName;

                        QueueingBasicConsumer consumer = new QueueingBasicConsumer(model);
                        model.BasicConsume(replyQueueName, true, consumer);

                        string queueName = model.QueueDeclare();

                        using (Subscription m_subscription = new Subscription(model, queueName))
                        {
                            // Subscription m_subscription = new Subscription(model, queueName);

                            string correlationId = Guid.NewGuid().ToString();
                            IBasicProperties basicProperties = model.CreateBasicProperties();
                            basicProperties.CorrelationId = correlationId;
                            basicProperties.ReplyTo = m_subscription.QueueName;

                            //发送请求
                            model.BasicPublish("", requestQueueName, basicProperties, request);

                            BasicDeliverEventArgs reply;
                            //接受返回值                     
                            if (!m_subscription.Next(this._timeOut, out reply))
                            {
                                if (TimedOutHandler != null)
                                    TimedOutHandler(this, null);
                                return null;
                            }

                            if (reply == null)
                            {
                                if (DisconnectedHandler != null)
                                    DisconnectedHandler(this, null);
                                return null;
                            }

                            if (reply.BasicProperties.CorrelationId != correlationId)
                            {
                                throw new ProtocolViolationException
                                    (string.Format("Wrong CorrelationId in reply; expected {0}, got {1}",
                                                   correlationId,
                                                   reply.BasicProperties.CorrelationId));
                            }

                            response = reply.Body;
                            //response = Encoding.UTF8.GetString(reply.Body);
                            m_subscription.Ack(reply);

                        }

                    }
                }
            }
            catch(Exception ex){
                PLog.Exception(ex);
            }

            return response;

        }

        ~RabbitMQHelper() {
            this._Cancelled = true;
            DisposeAllConnectionObjects();
        
        }


        private string _uri;

        public string uri
        {
            get { return _uri; }
            set { _uri = value; }
        }

        private string _hostName;

        public string hostName
        {
            get { return _hostName; }
            set { _hostName = value; }
        }

        private int _port = 5672;

        public int port
        {
            get { return _port; }
            set { _port = value; }
        }
	

        private string _vhost;

        public string vhost
        {
            get { return _vhost; }
            set { _vhost = value; }
        }
	

        private string _userName;

        public string userName
        {
            get { return _userName; }
            set { _userName = value; }
        }

        private string _password;

        public string password
        {
            get { return _password; }
            set { _password = value; }
        }

        private Exchange _exchange;

        public Exchange exchange
        {
            get { return _exchange; }
            set { _exchange = value; }
        }

        private Queue _queue;

        public Queue queue
        {
            get { return _queue; }
            set { _queue = value; }
        }
	

        private int _timeOut = Timeout.Infinite;

        public int timeOut
        {
            get { return _timeOut; }
            set { _timeOut = value; }
        }

        private ushort _requestedHeartbeat = 30;

        public ushort requestedHeartbeat
        {
            get { return _requestedHeartbeat; }
            set { _requestedHeartbeat = value; }
        }

        void IDisposable.Dispose()
        {
           
            this._Cancelled = true;
            DisposeAllConnectionObjects();
            connectionFactory = null;
            
        }

        public void Cancel() {
            this._Cancelled = true;
            DisposeAllConnectionObjects();
            connectionFactory = null;
        }
    }
}
