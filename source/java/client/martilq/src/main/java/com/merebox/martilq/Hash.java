package com.merebox.martilq;

import java.io.File;
import java.io.FileInputStream;
import java.security.MessageDigest;

public class Hash {
    
    public String Algorithm;
    public String Value;
    
    public static Hash GenerateHash(String algorithm, String filePath, String value)
    {

        Hash hash = new Hash();
        hash.Algorithm = algorithm;
        if (value == null)
        {
            try {
                algorithm = algorithm.substring(0,3)+"-"+algorithm.substring(3);

                File file = new File(filePath);
                MessageDigest digest = MessageDigest.getInstance(algorithm);
    
                FileInputStream fis = new FileInputStream(file);
                byte[] byteArray = new byte[1024];
                int bytesCount = 0; 
                while ((bytesCount = fis.read(byteArray)) != -1) {
                    digest.update(byteArray, 0, bytesCount);
                };
                fis.close();
                
                byte[] bytes = digest.digest();
                StringBuilder sb = new StringBuilder();
                for(int i=0; i< bytes.length ;i++)
                {
                    sb.append(Integer.toString((bytes[i] & 0xff) + 0x100, 16).substring(1));
                }
                hash.Value =sb.toString();
            } catch (Exception ex) {
                System.out.println("Exception in hash generation: "+ ex.getMessage());
                System.out.println("Algorithm: "+ algorithm);
                System.out.println("File: "+ filePath);
            }
        } else {
            hash.Value = value;
        }

        return hash;
    }

}
