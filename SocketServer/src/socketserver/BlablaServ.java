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
import java.util.*;

//** Classe principale du serveur, g�re les infos globales **
public class BlablaServ
{
  private Vector _tabClients = new Vector(); // contiendra tous les flux de sortie vers les clients
  private int _nbClients=0; // nombre total de clients connect�s




  //** Methode : envoie le message � tous les clients **
  synchronized public void sendAll(String message,String sLast)
  {
    PrintWriter out; // declaration d'une variable permettant l'envoie de texte vers le client
    for (int i = 0; i < _tabClients.size(); i++) // parcours de la table des connect�s
    {
      out = (PrintWriter) _tabClients.elementAt(i); // extraction de l'�l�ment courant (type PrintWriter)
      if (out != null) // s�curit�, l'�l�ment ne doit pas �tre vide
      {
      	// ecriture du texte pass� en param�tre (et concat�nation d'ue string de fin de chaine si besoin)
        out.print(message+sLast);
        out.flush(); // envoi dans le flux de sortie
      }
    }
  }

  //** Methode : détruit le client no i **
  synchronized public void delClient(int i)
  {
    _nbClients--; // un client en moins ! snif
    if (_tabClients.elementAt(i) != null) // l'�l�ment existe ...
    {
      _tabClients.removeElementAt(i); // ... on le supprime
    }
  }

  //** Methode : ajoute un nouveau client dans la liste **
  synchronized public int addClient(PrintWriter out)
  {
    _nbClients++; // un client en plus ! ouaaaih
    _tabClients.addElement(out); // on ajoute le nouveau flux de sortie au tableau
    return _tabClients.size()-1; // on retourne le num�ro du client ajout� (size-1)
  }

  //** Methode : retourne le nombre de clients connect�s **
  synchronized public int getNbClients()
  {
    return _nbClients; // retourne le nombre de clients connect�s
  }

}
