/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package socketserver;

import java.net.ServerSocket;

/**
 *
 * @author elias
 */
public class ServerLauncher implements Runnable {

    public ServerLauncher() {
        Thread t = new Thread(this); // instanciation du thread
        t.start();
    }

    public void run() {
        BlablaServ blablaServ = new BlablaServ(); // instance de la classe principale
        try {
            Integer port = new Integer("18000"); // si pas d'arguments : port 18000 par d�faut

            ServerSocket ss = new ServerSocket(port.intValue()); // ouverture d'un socket serveur sur port

            while (true) // attente en boucle de connexion (bloquant sur ss.accept)
            {
                new BlablaThread(ss.accept(), blablaServ); // un client se connecte, un nouveau thread client est lanc�
            }
        } catch (Exception e) {
        }
    }
}
