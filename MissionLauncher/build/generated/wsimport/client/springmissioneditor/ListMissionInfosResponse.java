
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
 *         &lt;element name="ListMissionInfosResult" type="{http://SpringMissionEditor/}ArrayOfMissionInfo" minOccurs="0"/>
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
    "listMissionInfosResult"
})
@XmlRootElement(name = "ListMissionInfosResponse")
public class ListMissionInfosResponse {

    @XmlElement(name = "ListMissionInfosResult")
    protected ArrayOfMissionInfo listMissionInfosResult;

    /**
     * Gets the value of the listMissionInfosResult property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfMissionInfo }
     *     
     */
    public ArrayOfMissionInfo getListMissionInfosResult() {
        return listMissionInfosResult;
    }

    /**
     * Sets the value of the listMissionInfosResult property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfMissionInfo }
     *     
     */
    public void setListMissionInfosResult(ArrayOfMissionInfo value) {
        this.listMissionInfosResult = value;
    }

}
