(ql:quickload '(clack websocket-driver alexandria serapeum))

(setf *print-array* t)

(serapeum:toggle-pretty-print-hash-table t)

(defvar *connections* (make-hash-table))

(print *connections*)

(defun handle-new-connection (ws)
  (setf (gethash ws *connections*)
        (concatenate
         'string
         "USER-" (write-to-string (random 1000000)))))

(defun broadcast-to-room (ws message)
  (print (write-to-string message))
  (let ((message (format nil "~a: ~a"
                         (gethash ws *connections*)
                         message)))
    (loop :for con :being :the :hash-key :of *connections* :do
      (websocket-driver:send con message))))

(defun handle-close-connection (connection)
  (let ((message (format nil " .... ~a has left."
                         (gethash connection *connections*))))
    (remhash connection *connections*)
    (loop :for con :being :the :hash-key :of *connections* :do
          (websocket-driver:send con message))))

(defun chat-server (env)
  (let ((ws (websocket-driver:make-server env)))
    (websocket-driver:on
     :open ws
     (lambda ()
       (handle-new-connection ws)))
    (websocket-driver:on
     :message ws
     (lambda (msg)
       (broadcast-to-room ws msg)))
    (websocket-driver:on
     :close ws
     (lambda (&key code reason)
       (declare (ignore code reason))
       (handle-close-connection ws)))
    (lambda (responder)
      (declare (ignore responder))
      (websocket-driver:start-connection ws))))

(defvar *html*
  "<!doctype html>

<html lang=\"en\">
<head>
  <meta charset=\"utf-8\">
  <title>LISP-CHAT</title>
</head>

<body>
    <ul id=\"chat-echo-area\">
    </ul>
    <div style=\"position:fixed; bottom:0;\">
        <input id=\"chat-input\" placeholder=\"say something\" >
    </div>
    <script>
     window.onload = function () {
         const inputField = document.getElementById(\"chat-input\");

         function receivedMessage(msg) {
             let li = document.createElement(\"li\");
             li.textContent = msg.data;
             document.getElementById(\"chat-echo-area\").appendChild(li);
         }

         const ws = new WebSocket(\"ws://localhost:12345/darren\");
         ws.addEventListener('message', receivedMessage);

         inputField.addEventListener(\"keyup\", (evt) => {
             if (evt.key === \"Enter\") {
                 ws.send(evt.target.value);
                 evt.target.value = \"\";
             }
         });
     };

    </script>
</body>
</html>
")

(defun client-server (env)
  (declare (ignore env))
  `(200 (:content-type "text/html")
     (,*html*)))

(defvar *chat-handler* (clack:clackup #'chat-server :port 12345))
(defvar *client-handler* (clack:clackup #'client-server :port 8080))
