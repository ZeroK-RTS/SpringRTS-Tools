
package springmissioneditor;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="GetScoresResult" type="{http://SpringMissionEditor/}ArrayOfScoreEntry" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "getScoresResult"
})
@XmlRootElement(name = "GetScoresResponse")
public class GetScoresResponse {

    @XmlElement(name = "GetScoresResult")
    protected ArrayOfScoreEntry getScoresResult;

    /**
     * Gets the value of the getScoresResult property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfScoreEntry }
     *     
     */
    public ArrayOfScoreEntry getGetScoresResult() {
        return getScoresResult;
    }

    /**
     * Sets the value of the getScoresResult property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfScoreEntry }
     *     
     */
    public void setGetScoresResult(ArrayOfScoreEntry value) {
        this.getScoresResult = value;
    }

}
