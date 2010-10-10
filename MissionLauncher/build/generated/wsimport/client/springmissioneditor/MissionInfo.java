
package springmissioneditor;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.datatype.XMLGregorianCalendar;


/**
 * <p>Java class for MissionInfo complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="MissionInfo">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="Author" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="CommentCount" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *         &lt;element name="CreatedTime" type="{http://www.w3.org/2001/XMLSchema}dateTime"/>
 *         &lt;element name="Description" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="DownloadCount" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *         &lt;element name="Image" type="{http://www.w3.org/2001/XMLSchema}base64Binary" minOccurs="0"/>
 *         &lt;element name="LastCommentTime" type="{http://www.w3.org/2001/XMLSchema}dateTime"/>
 *         &lt;element name="Map" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="MissionID" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *         &lt;element name="Mod" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="ModifiedTime" type="{http://www.w3.org/2001/XMLSchema}dateTime"/>
 *         &lt;element name="Name" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="Rating" type="{http://www.w3.org/2001/XMLSchema}double"/>
 *         &lt;element name="ScoringMethod" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="TopScoreLine" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "MissionInfo", propOrder = {
    "author",
    "commentCount",
    "createdTime",
    "description",
    "downloadCount",
    "image",
    "lastCommentTime",
    "map",
    "missionID",
    "mod",
    "modifiedTime",
    "name",
    "rating",
    "scoringMethod",
    "topScoreLine"
})
public class MissionInfo {

    @XmlElement(name = "Author")
    protected String author;
    @XmlElement(name = "CommentCount")
    protected int commentCount;
    @XmlElement(name = "CreatedTime", required = true, nillable = true)
    @XmlSchemaType(name = "dateTime")
    protected XMLGregorianCalendar createdTime;
    @XmlElement(name = "Description")
    protected String description;
    @XmlElement(name = "DownloadCount")
    protected int downloadCount;
    @XmlElement(name = "Image")
    protected byte[] image;
    @XmlElement(name = "LastCommentTime", required = true, nillable = true)
    @XmlSchemaType(name = "dateTime")
    protected XMLGregorianCalendar lastCommentTime;
    @XmlElement(name = "Map")
    protected String map;
    @XmlElement(name = "MissionID")
    protected int missionID;
    @XmlElement(name = "Mod")
    protected String mod;
    @XmlElement(name = "ModifiedTime", required = true, nillable = true)
    @XmlSchemaType(name = "dateTime")
    protected XMLGregorianCalendar modifiedTime;
    @XmlElement(name = "Name")
    protected String name;
    @XmlElement(name = "Rating")
    protected double rating;
    @XmlElement(name = "ScoringMethod")
    protected String scoringMethod;
    @XmlElement(name = "TopScoreLine")
    protected String topScoreLine;

    /**
     * Gets the value of the author property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuthor() {
        return author;
    }

    /**
     * Sets the value of the author property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuthor(String value) {
        this.author = value;
    }

    /**
     * Gets the value of the commentCount property.
     * 
     */
    public int getCommentCount() {
        return commentCount;
    }

    /**
     * Sets the value of the commentCount property.
     * 
     */
    public void setCommentCount(int value) {
        this.commentCount = value;
    }

    /**
     * Gets the value of the createdTime property.
     * 
     * @return
     *     possible object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public XMLGregorianCalendar getCreatedTime() {
        return createdTime;
    }

    /**
     * Sets the value of the createdTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public void setCreatedTime(XMLGregorianCalendar value) {
        this.createdTime = value;
    }

    /**
     * Gets the value of the description property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDescription() {
        return description;
    }

    /**
     * Sets the value of the description property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDescription(String value) {
        this.description = value;
    }

    /**
     * Gets the value of the downloadCount property.
     * 
     */
    public int getDownloadCount() {
        return downloadCount;
    }

    /**
     * Sets the value of the downloadCount property.
     * 
     */
    public void setDownloadCount(int value) {
        this.downloadCount = value;
    }

    /**
     * Gets the value of the image property.
     * 
     * @return
     *     possible object is
     *     byte[]
     */
    public byte[] getImage() {
        return image;
    }

    /**
     * Sets the value of the image property.
     * 
     * @param value
     *     allowed object is
     *     byte[]
     */
    public void setImage(byte[] value) {
        this.image = ((byte[]) value);
    }

    /**
     * Gets the value of the lastCommentTime property.
     * 
     * @return
     *     possible object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public XMLGregorianCalendar getLastCommentTime() {
        return lastCommentTime;
    }

    /**
     * Sets the value of the lastCommentTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public void setLastCommentTime(XMLGregorianCalendar value) {
        this.lastCommentTime = value;
    }

    /**
     * Gets the value of the map property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMap() {
        return map;
    }

    /**
     * Sets the value of the map property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMap(String value) {
        this.map = value;
    }

    /**
     * Gets the value of the missionID property.
     * 
     */
    public int getMissionID() {
        return missionID;
    }

    /**
     * Sets the value of the missionID property.
     * 
     */
    public void setMissionID(int value) {
        this.missionID = value;
    }

    /**
     * Gets the value of the mod property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMod() {
        return mod;
    }

    /**
     * Sets the value of the mod property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMod(String value) {
        this.mod = value;
    }

    /**
     * Gets the value of the modifiedTime property.
     * 
     * @return
     *     possible object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public XMLGregorianCalendar getModifiedTime() {
        return modifiedTime;
    }

    /**
     * Sets the value of the modifiedTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public void setModifiedTime(XMLGregorianCalendar value) {
        this.modifiedTime = value;
    }

    /**
     * Gets the value of the name property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the value of the name property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setName(String value) {
        this.name = value;
    }

    /**
     * Gets the value of the rating property.
     * 
     */
    public double getRating() {
        return rating;
    }

    /**
     * Sets the value of the rating property.
     * 
     */
    public void setRating(double value) {
        this.rating = value;
    }

    /**
     * Gets the value of the scoringMethod property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getScoringMethod() {
        return scoringMethod;
    }

    /**
     * Sets the value of the scoringMethod property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setScoringMethod(String value) {
        this.scoringMethod = value;
    }

    /**
     * Gets the value of the topScoreLine property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTopScoreLine() {
        return topScoreLine;
    }

    /**
     * Sets the value of the topScoreLine property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTopScoreLine(String value) {
        this.topScoreLine = value;
    }

}
