
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
 *         &lt;element name="GetMissionResult" type="{http://SpringMissionEditor/}MissionData" minOccurs="0"/>
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
    "getMissionResult"
})
@XmlRootElement(name = "GetMissionResponse")
public class GetMissionResponse {

    @XmlElement(name = "GetMissionResult")
    protected MissionData getMissionResult;

    /**
     * Gets the value of the getMissionResult property.
     * 
     * @return
     *     possible object is
     *     {@link MissionData }
     *     
     */
    public MissionData getGetMissionResult() {
        return getMissionResult;
    }

    /**
     * Sets the value of the getMissionResult property.
     * 
     * @param value
     *     allowed object is
     *     {@link MissionData }
     *     
     */
    public void setGetMissionResult(MissionData value) {
        this.getMissionResult = value;
    }

}
