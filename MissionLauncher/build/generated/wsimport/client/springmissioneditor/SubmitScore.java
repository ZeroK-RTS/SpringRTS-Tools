
package springmissioneditor;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
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
 *         &lt;element name="missionName" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="playerName" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="score" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *         &lt;element name="timeSeconds" type="{http://www.w3.org/2001/XMLSchema}int"/>
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
    "missionName",
    "playerName",
    "score",
    "timeSeconds"
})
@XmlRootElement(name = "SubmitScore")
public class SubmitScore {

    protected String missionName;
    protected String playerName;
    protected int score;
    protected int timeSeconds;

    /**
     * Gets the value of the missionName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMissionName() {
        return missionName;
    }

    /**
     * Sets the value of the missionName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMissionName(String value) {
        this.missionName = value;
    }

    /**
     * Gets the value of the playerName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPlayerName() {
        return playerName;
    }

    /**
     * Sets the value of the playerName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPlayerName(String value) {
        this.playerName = value;
    }

    /**
     * Gets the value of the score property.
     * 
     */
    public int getScore() {
        return score;
    }

    /**
     * Sets the value of the score property.
     * 
     */
    public void setScore(int value) {
        this.score = value;
    }

    /**
     * Gets the value of the timeSeconds property.
     * 
     */
    public int getTimeSeconds() {
        return timeSeconds;
    }

    /**
     * Sets the value of the timeSeconds property.
     * 
     */
    public void setTimeSeconds(int value) {
        this.timeSeconds = value;
    }

}
