
package springmissioneditor;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ArrayOfScoreEntry complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ArrayOfScoreEntry">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="ScoreEntry" type="{http://SpringMissionEditor/}ScoreEntry" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ArrayOfScoreEntry", propOrder = {
    "scoreEntry"
})
public class ArrayOfScoreEntry {

    @XmlElement(name = "ScoreEntry", nillable = true)
    protected List<ScoreEntry> scoreEntry;

    /**
     * Gets the value of the scoreEntry property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the scoreEntry property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getScoreEntry().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ScoreEntry }
     * 
     * 
     */
    public List<ScoreEntry> getScoreEntry() {
        if (scoreEntry == null) {
            scoreEntry = new ArrayList<ScoreEntry>();
        }
        return this.scoreEntry;
    }

}
