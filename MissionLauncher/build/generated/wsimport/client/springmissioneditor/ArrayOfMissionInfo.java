
package springmissioneditor;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for ArrayOfMissionInfo complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="ArrayOfMissionInfo">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="MissionInfo" type="{http://SpringMissionEditor/}MissionInfo" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "ArrayOfMissionInfo", propOrder = {
    "missionInfo"
})
public class ArrayOfMissionInfo {

    @XmlElement(name = "MissionInfo", nillable = true)
    protected List<MissionInfo> missionInfo;

    /**
     * Gets the value of the missionInfo property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the missionInfo property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getMissionInfo().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link MissionInfo }
     * 
     * 
     */
    public List<MissionInfo> getMissionInfo() {
        if (missionInfo == null) {
            missionInfo = new ArrayList<MissionInfo>();
        }
        return this.missionInfo;
    }

}
