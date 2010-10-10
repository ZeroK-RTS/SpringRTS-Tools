
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
 *         &lt;element name="ListCommentsResult" type="{http://SpringMissionEditor/}ArrayOfCommentInfo" minOccurs="0"/>
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
    "listCommentsResult"
})
@XmlRootElement(name = "ListCommentsResponse")
public class ListCommentsResponse {

    @XmlElement(name = "ListCommentsResult")
    protected ArrayOfCommentInfo listCommentsResult;

    /**
     * Gets the value of the listCommentsResult property.
     * 
     * @return
     *     possible object is
     *     {@link ArrayOfCommentInfo }
     *     
     */
    public ArrayOfCommentInfo getListCommentsResult() {
        return listCommentsResult;
    }

    /**
     * Sets the value of the listCommentsResult property.
     * 
     * @param value
     *     allowed object is
     *     {@link ArrayOfCommentInfo }
     *     
     */
    public void setListCommentsResult(ArrayOfCommentInfo value) {
        this.listCommentsResult = value;
    }

}
