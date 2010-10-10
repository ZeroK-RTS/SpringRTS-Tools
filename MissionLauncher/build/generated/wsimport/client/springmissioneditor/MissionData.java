
package springmissioneditor;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for MissionData complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="MissionData">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="MissionInfo" type="{http://SpringMissionEditor/}MissionInfo" minOccurs="0"/>
 *         &lt;element name="Mutator" type="{http://www.w3.org/2001/XMLSchema}base64Binary" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "MissionData", propOrder = {
    "missionInfo",
    "mutator"
})
public class MissionData {

    @XmlElement(name = "MissionInfo")
    protected MissionInfo missionInfo;
    @XmlElement(name = "Mutator")
    protected byte[] mutator;

    /**
     * Gets the value of the missionInfo property.
     * 
     * @return
     *     possible object is
     *     {@link MissionInfo }
     *     
     */
    public MissionInfo getMissionInfo() {
        return missionInfo;
    }

    /**
     * Sets the value of the missionInfo property.
     * 
     * @param value
     *     allowed object is
     *     {@link MissionInfo }
     *     
     */
    public void setMissionInfo(MissionInfo value) {
        this.missionInfo = value;
    }

    /**
     * Gets the value of the mutator property.
     * 
     * @return
     *     possible object is
     *     byte[]
     */
    public byte[] getMutator() {
        return mutator;
    }

    /**
     * Sets the value of the mutator property.
     * 
     * @param value
     *     allowed object is
     *     byte[]
     */
    public void setMutator(byte[] value) {
        this.mutator = ((byte[]) value);
    }

}
