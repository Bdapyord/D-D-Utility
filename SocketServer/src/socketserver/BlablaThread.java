package socketserver;

/**
 * <p>Title: BlablaServeur</p>
 * <p>Company: Minosis.com</p>
 * <p>Date: 27/03/2005</p>
 * @author Minosis - Julien Defaut
 * @version 1.0
 */

import java.net.*;
import java.io.*;

//** Classe associ�e � chaque client **
//** Il y aura autant d'instance de cette classe que de client connect�s **
//impl�mentation de l'interface Runnable (une des 2 m�thodes pour cr�er un thread)
class BlablaThread implements Runnable
{
  private Thread _t; // contiendra le thread du client
  private Socket _s; // recevra le socket liant au client
  private PrintWriter _out; // pour gestion du flux de sortie
  private BufferedReader _in; // pour gestion du flux d'entr�e
  private BlablaServ _blablaServ; // pour utilisation des m�thodes de la classe principale
  private int _numClient=0; // contiendra le num�ro de client g�r� par ce thread

  //** Constructeur : cr�e les �l�ments n�cessaires au dialogue avec le client **
  BlablaThread(Socket s, BlablaServ blablaServ) // le param s est donn�e dans BlablaServ par ss.accept()
  {
    _blablaServ=blablaServ; // passage de local en global (pour gestion dans les autres m�thodes)
    _s=s; // passage de local en global
    try
    {
      // fabrication d'une variable permettant l'utilisation du flux de sortie avec des string
      _out = new PrintWriter(_s.getOutputStream());
      // fabrication d'une variable permettant l'utilisation du flux d'entr�e avec des string
      _in = new BufferedReader(new InputStreamReader(_s.getInputStream()));
      // ajoute le flux de sortie dans la liste et r�cup�ration de son numero
      _numClient = blablaServ.addClient(_out);
    }
    catch (IOException e){ }

    _t = new Thread(this); // instanciation du thread
    _t.start(); // demarrage du thread, la fonction run() est ici lanc�e
  }

  //** Methode :  ex�cut�e au lancement du thread par t.start() **
  //** Elle attend les messages en provenance du serveur et les redirige **
  // cette m�thode doit obligatoirement �tre impl�ment�e � cause de l'interface Runnable
  public void run()
  {
    String message = ""; // d�claration de la variable qui recevra les messages du client
    // on indique dans la console la connection d'un nouveau client
    System.out.println("Un nouveau client s'est connecte, no "+_numClient);
    try
    {
      // la lecture des donn�es entrantes se fait caract�re par caract�re ...
      // ... jusqu'� trouver un caract�re de fin de chaine
      char charCur[] = new char[1]; // d�claration d'un tableau de char d'1 �lement, _in.read() stockera y le char lu
      while(_in.read(charCur, 0, 1)!=-1) // attente en boucle des messages provenant du client (bloquant sur _in.read())
      {
      	// on regarde si on arrive � la fin d'une chaine ...
        if (charCur[0] != '\u0000' && charCur[0] != '\n' && charCur[0] != '\r')
                message += charCur[0]; // ... si non, on concat�ne le caract�re dans le message
        else if(!message.equalsIgnoreCase("")) // juste une v�rification de principe
        {
          if(charCur[0]=='\u0000') // le dernier caract�re �tait '\u0000' (char de terminaison nulle)
          	// on envoi le message en disant qu'il faudra concat�ner '\u0000' lors de l'envoi au client
            _blablaServ.sendAll(message,""+charCur[0]);
          else _blablaServ.sendAll(message,""); // sinon on envoi le message � tous
          message = ""; // on vide la chaine de message pour qu'elle soit r�utilis�e
        }
      }
    }
    catch (Exception e){ }
    finally // finally se produira le plus souvent lors de la deconnexion du client
    {
      try
      {
      	// on indique � la console la deconnexion du client
        System.out.println("Le client no "+_numClient+" s'est deconnecte");
        _blablaServ.delClient(_numClient); // on supprime le client de la liste
        _s.close(); // fermeture du socket si il ne l'a pas d�j� �t� (� cause de l'exception lev�e plus haut)
      }
      catch (IOException e){ }
    }
  }
}
