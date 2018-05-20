/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/*
 * MainWindow.java
 *
 * Created on Apr 3, 2009, 3:03:13 PM
 */

package missionlauncher;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import javax.swing.table.DefaultTableModel;
import springmissioneditor.EditorService;
import springmissioneditor.EditorServiceSoap;
import springmissioneditor.MissionData;
import springmissioneditor.MissionInfo;

/**
 *
 * @author Administrator
 */
public class readFileLine extends javax.swing.JFrame {

     final String[] columnNames = {
        "Rating",
        "Title",
        "Author",
        "Description",
        "Game",
        "Map",
        "Downloads",
        "Created",
        "Modified",
     };

     public String convertStreamToString(InputStream is) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        StringBuilder sb = new StringBuilder();
        String line = null;
        try {
            while ((line = reader.readLine()) != null) {
                sb.append(line + "\n");
            }
        } finally {
            is.close();
        }
        return sb.toString();
    }

    public static String readTextFile(String fullPathFilename) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(fullPathFilename));
        try {
            return reader.readLine();
        } finally {
            reader.close();
        }
    }

    public static void writeTextFile(String contents, String fullPathFilename) throws IOException {
        BufferedWriter writer = new BufferedWriter(new FileWriter(fullPathFilename));
        try {
            writer.write(contents);
            writer.flush();
        } finally {
            writer.close();
        }
    }


    String getStringFromZip(String zipPath, String filePath) throws IOException{
        ZipFile zipFile = new ZipFile(zipPath);
        ZipEntry zipEntry = new ZipEntry(filePath);
        InputStream inputStream = zipFile.getInputStream(zipEntry);
        try {
            return convertStreamToString(inputStream);
        } finally {
            inputStream.close();
            zipFile.close();
        }

     }

    void writeBytesToFile(String path, byte[] bytes) throws FileNotFoundException, IOException {
        FileOutputStream stream = new FileOutputStream(path);
        try {
            stream.write(bytes);
        } finally {
            stream.close();
        }
    }


     void playMission()
     {
        String title = (String)missionTable.getModel().getValueAt(missionTable.getSelectedRow(), 1);
        if (title == null) return;
        try {
            EditorServiceSoap client = new EditorService().getEditorServiceSoap12();
            MissionData missionData = client.getMission(title);
            char[] invalidChars = {':', '\\', '*', '?', '"', '<', '>', '|', ' '}; // how to get invalid filename characters in java?
            String missionFileName = missionData.getMissionInfo().getName() + ".sdz";
            for (char invalidChar : invalidChars) missionFileName = missionFileName.replace(invalidChar, '_');
            String missionPath = modsPath + File.separator + missionFileName;
            writeBytesToFile(missionPath, missionData.getMutator());
            String script = getStringFromZip(missionPath, "script.txt");
            script = script.replaceAll("GameType=.+?;", "GameType=" + missionData.getMissionInfo().getName() + ";");
            script = script.replaceAll("aidll=.+?;", "aidll=LuaAI:none;");
            File scriptFile = File.createTempFile("script", ".txt");
            scriptFile.deleteOnExit();
            writeTextFile(script, scriptFile.getAbsolutePath());
            String[] command = {quote(executablePath), quote(scriptFile.getAbsolutePath())};
            Runtime.getRuntime().exec(command);
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this,ex.getMessage());
        }

     }

     String quote(String s) {
        if (System.getProperty("os.name").contains("Linux")) {
            return s;
        }
        return "\"" + s + "\"";
     }

     void refreshMissionList() {
        try {
            EditorServiceSoap client = new EditorService().getEditorServiceSoap12();
            List<MissionInfo> missionInfos = client.listMissionInfos().getMissionInfo();
            Object[][] data = new Object[missionInfos.size()][columnNames.length];
            for (int i=0; i < missionInfos.size(); i++) {
                MissionInfo info = missionInfos.get(i);
                data[i][0] = info.getRating();
                data[i][1] = info.getName();
                data[i][2] = info.getAuthor();
                data[i][3] = info.getDescription();
                data[i][4] = info.getMod();
                data[i][5] = info.getMap();
                data[i][6] = info.getDownloadCount();
                data[i][7] = info.getModifiedTime();
                data[i][8] = info.getCreatedTime();
            }
            missionTable.setModel(new DefaultTableModel(data, columnNames));
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this,ex.getMessage());
        }
     }
    String executablePath = "/usr/games/spring";
    String modsPath = System.getProperty("user.home") + "/.spring/mods";

    final String EXE_SAVE_FILE = "springexe";
    final String MODS_SAVE_FILE = "modspath";

    /** Creates new form MainWindow */

    public readFileLine() {
        initComponents();
        refreshMissionList();
        try {
            executablePath = readTextFile(EXE_SAVE_FILE);
        } catch (IOException ex) { } // keep default value
        try {
            modsPath = readTextFile(MODS_SAVE_FILE);
        } catch (IOException ex) { }
    }

    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jScrollPane1 = new javax.swing.JScrollPane();
        missionTable = new javax.swing.JTable();
        jToolBar1 = new javax.swing.JToolBar();
        playButton = new javax.swing.JButton();
        refreshButton = new javax.swing.JButton();
        executableButton = new javax.swing.JButton();
        modsFolderButton = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);

        missionTable.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {

            },
            new String [] {

            }
        ));
        jScrollPane1.setViewportView(missionTable);

        jToolBar1.setRollover(true);

        playButton.setText("Play");
        playButton.setFocusable(false);
        playButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
        playButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
        playButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                playButtonActionPerformed(evt);
            }
        });
        jToolBar1.add(playButton);

        refreshButton.setText("Refresh");
        refreshButton.setFocusable(false);
        refreshButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
        refreshButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
        refreshButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                refreshButtonActionPerformed(evt);
            }
        });
        jToolBar1.add(refreshButton);

        executableButton.setText("Select Executable");
        executableButton.setFocusable(false);
        executableButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
        executableButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
        executableButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                executableButtonActionPerformed(evt);
            }
        });
        jToolBar1.add(executableButton);

        modsFolderButton.setText("Select Mods Folder");
        modsFolderButton.setFocusable(false);
        modsFolderButton.setHorizontalTextPosition(javax.swing.SwingConstants.CENTER);
        modsFolderButton.setVerticalTextPosition(javax.swing.SwingConstants.BOTTOM);
        modsFolderButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                modsFolderButtonActionPerformed(evt);
            }
        });
        jToolBar1.add(modsFolderButton);

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 747, Short.MAX_VALUE)
            .addComponent(jToolBar1, javax.swing.GroupLayout.DEFAULT_SIZE, 747, Short.MAX_VALUE)
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addComponent(jScrollPane1, javax.swing.GroupLayout.DEFAULT_SIZE, 381, Short.MAX_VALUE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jToolBar1, javax.swing.GroupLayout.PREFERRED_SIZE, 25, javax.swing.GroupLayout.PREFERRED_SIZE))
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void refreshButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_refreshButtonActionPerformed
        refreshMissionList();
    }//GEN-LAST:event_refreshButtonActionPerformed

    private void playButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_playButtonActionPerformed
        playMission();
    }//GEN-LAST:event_playButtonActionPerformed

    private void executableButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_executableButtonActionPerformed
        JFileChooser chooser = new JFileChooser(executablePath);
        chooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
        if(chooser.showOpenDialog(this) == JFileChooser.APPROVE_OPTION) {
            executablePath = chooser.getSelectedFile().getAbsolutePath();
            try {
                writeTextFile(executablePath, EXE_SAVE_FILE);
            } catch (IOException e) { } // not worth dying for
        }
    }//GEN-LAST:event_executableButtonActionPerformed

    private void modsFolderButtonActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_modsFolderButtonActionPerformed
        JFileChooser chooser = new JFileChooser(modsPath);
        chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
        if(chooser.showOpenDialog(this) == JFileChooser.APPROVE_OPTION) {
            modsPath = chooser.getSelectedFile().getAbsolutePath();
            try {
                writeTextFile(modsPath, MODS_SAVE_FILE);
            } catch (IOException e) { }
        }
}//GEN-LAST:event_modsFolderButtonActionPerformed

    /**
    * @param args the command line arguments
    */
    public static void main(String args[]) {
        java.awt.EventQueue.invokeLater(new Runnable() {
            public void run() {
                new readFileLine().setVisible(true);
            }
        });
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton executableButton;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JToolBar jToolBar1;
    public javax.swing.JTable missionTable;
    private javax.swing.JButton modsFolderButton;
    private javax.swing.JButton playButton;
    public javax.swing.JButton refreshButton;
    // End of variables declaration//GEN-END:variables

}
