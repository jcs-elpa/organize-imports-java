package com.aldes.jcs;

import java.awt.FlowLayout;
import java.lang.Runnable;

import javax.swing.JFrame;
import javax.swing.JFrame;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JList;
import javax.swing.ListSelectionModel;
import javax.swing.SwingUtilities;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

/**
 * $File: TestMain.java $
 * $Date: 2018-04-16 15:56:52 $
 * $Revision: $
 * $Creator: Jen-Chieh Shen $
 * $Notice: See LICENSE.txt for modification and distribution information
 *                   Copyright © 2018 by Shen, Jen-Chieh $
 */


/**
 * Test of the program.
 *
 * @note this file does not need to be compile.
 * This file only matter to test if the Emacs do the
 * right thing to us.
 */
public class TestMain {
    JLabel label;
    JList list;
    String[] nycsites;

    public Lists() {
        label = new JLabel("");
        nycsites = new String[] { "Empire State Building", "Ground Zero",
                                  "Statue of Liberty", "Wall Street", "Central Park",
                                  "Times Square" };
        list = new JList(nycsites);
        list.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        list.addListSelectionListener(new ListSelectionListener(){
                public void valueChanged(ListSelectionEvent le){
                    int index = list.getSelectedIndex();
                    if(index != -1){
                        label.setText("Site to visit: " + nycsites[index]);
                    }
                }
            });
        JFrame frame = new JFrame("Using Lists");
        frame.setLayout(new FlowLayout());
        frame.setSize(500, 250);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.add(list);
        frame.add(label);
        frame.setVisible(true);
    }

    public static void main(String[] args){
        SwingUtilities.invokeLater(new Runnable(){
                public void run(){
                    new Lists();
                }
            });


    }
}
